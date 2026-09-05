# Include optional .env file
-include .env

# =============================================================================
# Build configuration (override via env, .env, or command line)
# =============================================================================

TAG_BASE ?= paularlott
CACHE_TAG_BASE ?= $(TAG_BASE)
DOCKER_HUB ?=
APT_CACHE ?=

# Destination namespace for 'make copy', which mirrors the built images from
# TAG_BASE through the docker daemon instead of rebuilding them for a second
# registry. Requires the containerd image store for multi-platform pushes.
COPY_TAG_BASE ?= docker.io/paularlott

# Per-tag copy attempts for 'make copy', with a backoff between tries;
# already-pushed layers are skipped on retry.
COPY_RETRIES ?= 3

# Backoff between copy attempts: attempt * COPY_BACKOFF seconds.
COPY_BACKOFF ?= 30

# Platforms pulled and re-pushed by 'make copy' (keep in sync with bake).
COPY_PLATFORMS ?= linux/amd64 linux/arm64

UBUNTU_VERSIONS ?= 26.04
PHP_UBUNTU_BASE_VERSION ?= 26.04
UBUNTU_BASE_VERSION ?= 26.04
PHP_VERSIONS ?= 8.4 8.5
GO_VERSIONS ?= 1.26
PYTHON_VERSIONS ?= 3.14
NODE_VERSIONS ?= 24 26
FRANKENPHP_VERSIONS ?= 8.5
SCRIPTLING_VERSIONS ?= 0.24.3
KNOT_ALPINE_VERSIONS ?= 3.24
KNOT_ALPINE_BASE_VERSION ?= 3.24
MARIADB_VERSIONS ?= 10.11 11.4 11.8 12.3
MYSQL_VERSIONS ?= 9.7
POSTGRES_VERSIONS ?= 18
VALKEY_VERSIONS ?= 9.0.4 9.1.1
REDIS_VERSIONS ?= 8.10.0
MAILPIT_VERSIONS ?= 1.30
ADMINER_VERSIONS ?= 6.0.1
VICTORIA_LOGS_VERSIONS ?= 1.52.0
VMAUTH_VERSION ?= 1.148.0
ALPINE_VERSION ?= 3.20
CADDY_VERSION ?= 2.11.4
FRANKENPHP_VERSION ?= 1.12.7
SCRIPTLING_VERSION ?= v0.24.3

BUILD_DATE ?= $(shell date -u +'%Y%m%d')

# =============================================================================
# Internal helpers — bake parses list-typed env vars as CSV, so we convert
# Make's space-separated lists before exporting.
# =============================================================================

empty :=
space := $(empty) $(empty)
comma := ,

export TAG_BASE
export CACHE_TAG_BASE
export DOCKER_HUB
export APT_CACHE
export UBUNTU_VERSION
export PHP_UBUNTU_BASE_VERSION
export UBUNTU_BASE_VERSION
export CADDY_VERSION
export FRANKENPHP_VERSION
export SCRIPTLING_VERSION
export KNOT_ALPINE_BASE_VERSION
export UBUNTU_VERSIONS := $(subst $(space),$(comma),$(UBUNTU_VERSIONS))
export PHP_VERSIONS := $(subst $(space),$(comma),$(PHP_VERSIONS))
export FRANKENPHP_VERSIONS := $(subst $(space),$(comma),$(FRANKENPHP_VERSIONS))
export SCRIPTLING_VERSIONS := $(subst $(space),$(comma),$(SCRIPTLING_VERSIONS))
export KNOT_ALPINE_VERSIONS := $(subst $(space),$(comma),$(KNOT_ALPINE_VERSIONS))
export GO_VERSIONS := $(subst $(space),$(comma),$(GO_VERSIONS))
export PYTHON_VERSIONS := $(subst $(space),$(comma),$(PYTHON_VERSIONS))
export NODE_VERSIONS := $(subst $(space),$(comma),$(NODE_VERSIONS))
export MARIADB_VERSIONS := $(subst $(space),$(comma),$(MARIADB_VERSIONS))
export MYSQL_VERSIONS := $(subst $(space),$(comma),$(MYSQL_VERSIONS))
export POSTGRES_VERSIONS := $(subst $(space),$(comma),$(POSTGRES_VERSIONS))
export VALKEY_VERSIONS := $(subst $(space),$(comma),$(VALKEY_VERSIONS))
export REDIS_VERSIONS := $(subst $(space),$(comma),$(REDIS_VERSIONS))
export MAILPIT_VERSIONS := $(subst $(space),$(comma),$(MAILPIT_VERSIONS))
export ADMINER_VERSIONS := $(subst $(space),$(comma),$(ADMINER_VERSIONS))
export VICTORIA_LOGS_VERSIONS := $(subst $(space),$(comma),$(VICTORIA_LOGS_VERSIONS))
export VMAUTH_VERSION
export ALPINE_VERSION
export BUILD_DATE

# Optional extra flags passed to bake (e.g. make BAKE_FLAGS=--print)
BAKE_FLAGS ?=

.DEFAULT_GOAL := all

.PHONY: all
## Build all targets (uses docker buildx bake for parallel builds)
all:
	docker buildx bake $(BAKE_FLAGS)

.PHONY: print
## Print the resolved bake configuration without building
print:
	docker buildx bake --print

.PHONY: list
## List available bake targets
list:
	docker buildx bake --list=targets

.PHONY: copy
## Copy built images from TAG_BASE to COPY_TAG_BASE via the docker daemon (no rebuild)
copy:
	@set -eu; \
	if [ "$$(docker info --format '{{.Driver}}' 2>/dev/null)" != "overlayfs" ]; then \
		echo "copy: the docker daemon must use the containerd image store" >&2; \
		echo "copy: Docker Desktop -> Settings -> General -> 'Use containerd for pulling and storing images'" >&2; \
		exit 1; \
	fi; \
	src='$(TAG_BASE)'; \
	dst='$(COPY_TAG_BASE)'; dst="$${dst%/}"; \
	if [ "$${src#docker.io/}" = "$${dst#docker.io/}" ]; then \
		echo "copy: COPY_TAG_BASE ($$dst) is the same namespace as TAG_BASE ($$src), nothing to copy" >&2; \
		exit 1; \
	fi; \
	tags=; \
	for target in $(TARGETS); do \
		target=$$(printf '%s' "$$target" | tr '.' '-'); \
		out=$$(docker buildx bake --print $$target 2>/dev/null | jq -r --arg t "$$target" '.target | to_entries[] | select(.key == $$t or (.key | test("^" + $$t + "-[0-9]"))) | .value.tags[]') || exit 1; \
		[ -n "$$out" ] || { echo "copy: no tags resolved for target $$target" >&2; exit 1; }; \
		tags="$$tags $$out"; \
	done; \
	if [ -z "$$tags" ]; then \
		tags=$$(docker buildx bake --print 2>/dev/null | jq -r '[.target[].tags[]] | unique | .[]') || exit 1; \
	fi; \
	[ -n "$$tags" ] || { echo 'copy: no tags resolved' >&2; exit 1; }; \
	tags=$$(printf '%s\n' $$tags | sort -u); \
	copy_tag() { \
		for platform in $(COPY_PLATFORMS); do \
			echo "  pulling $$platform"; \
			docker pull --platform "$$platform" "$$1" || return 1; \
		done; \
		docker tag "$$1" "$$2" || return 1; \
		echo "  pushing"; \
		docker push "$$2" || return 1; \
		docker image rm "$$1" "$$2" >/dev/null 2>&1 || true; \
	}; \
	copied=0; current=0; skipped=0; failed=; \
	for tag in $$tags; do \
		dest="$$dst$${tag#$$src}"; \
		src_children=$$(docker manifest inspect "$$tag" 2>/dev/null | jq -r '[(.manifests[]?.digest), (.config.digest // empty)] | sort | .[]') || src_children=; \
		if [ -z "$$src_children" ]; then \
			echo "==> $$tag -> $$dest  [skipped: not in source registry — built under a different BUILD_DATE?]" >&2; \
			skipped=$$((skipped + 1)); \
			continue; \
		fi; \
		dst_children=$$(docker manifest inspect "$$dest" 2>/dev/null | jq -r '[(.manifests[]?.digest), (.config.digest // empty)] | sort | .[]') || dst_children=; \
		if [ -n "$$dst_children" ] && [ "$$src_children" = "$$dst_children" ]; then \
			echo "==> $$tag -> $$dest  [up to date]"; \
			current=$$((current + 1)); \
			continue; \
		fi; \
		echo "==> $$tag -> $$dest"; \
		ok=0; \
		for attempt in $$(seq 1 $(COPY_RETRIES)); do \
			if copy_tag "$$tag" "$$dest"; then ok=1; break; fi; \
			if [ "$$attempt" -eq $(COPY_RETRIES) ]; then break; fi; \
			echo "copy: attempt $$attempt/$(COPY_RETRIES) for $$tag failed, retrying in $$((attempt * $(COPY_BACKOFF)))s" >&2; \
			sleep $$((attempt * $(COPY_BACKOFF))); \
		done; \
		if [ "$$ok" -eq 1 ]; then \
			copied=$$((copied + 1)); \
		else \
			echo "copy: FAILED $$tag -> $$dest" >&2; \
			failed="$$failed$$tag "; \
		fi; \
	done; \
	echo "copy: $$copied tag(s) copied, $$current already up to date, $$skipped skipped"; \
	if [ -n "$$failed" ]; then \
		echo "copy: failed after $(COPY_RETRIES) attempts:$$failed" >&2; \
		exit 1; \
	fi; \
	[ $$((copied + current)) -gt 0 ] || { echo 'copy: nothing was copied' >&2; exit 1; }

# .PHONY: knot-php
# ## Build all PHP versions sequentially (avoids resource exhaustion)
# knot-php:
# 	@for v in $(subst $(comma), ,$(PHP_VERSIONS)); do \
# 		echo "==> Building knot-php $${v}"; \
# 		docker buildx bake $(BAKE_FLAGS) "knot-php-$$(echo $$v | tr '.' '-')" || exit 1; \
# 	done

# .PHONY: knot-frankenphp
# ## Build all FrankenPHP versions sequentially (avoids resource exhaustion)
# knot-frankenphp:
# 	@for v in $(subst $(comma), ,$(FRANKENPHP_VERSIONS)); do \
# 		echo "==> Building knot-frankenphp $${v}"; \
# 		docker buildx bake $(BAKE_FLAGS) "knot-frankenphp-$$(echo $$v | tr '.' '-')" || exit 1; \
# 	done

.PHONY: knot-%
## Forward any knot-* target to bake (e.g. make knot-ubuntu-26.04, make knot-caddy)
knot-%:
	docker buildx bake $(BAKE_FLAGS) knot-$(subst .,-,$*)

.PHONY: help
## This help screen
help:
	@printf "Available targets:\n\n"
	@awk '/^[a-zA-Z\-_0-9%:\\]+/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			gsub("\\\\", "", helpCommand); \
			gsub(":+$$", "", helpCommand); \
			printf "  \x1b[32;01m%-20s\x1b[0m %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST) | sort -u
	@printf "\nBake targets (invoke as 'make knot-<name>'):\n\n"
	@docker buildx bake --list=targets 2>/dev/null | tail -n +2 || true
	@printf "\n"
