# Include optional .env file
-include .env

# =============================================================================
# Build configuration (override via env, .env, or command line)
# =============================================================================

TAG_BASE ?= paularlott
CACHE_TAG_BASE ?= $(TAG_BASE)
DOCKER_HUB ?=
APT_CACHE ?=

UBUNTU_VERSIONS ?= 24.04 26.04
PHP_UBUNTU_BASE_VERSION ?= 26.04
PHP_VERSIONS ?= 8.3 8.4 8.5
FRANKENPHP_VERSIONS ?= 8.4 8.5
MARIADB_VERSIONS ?= 10.11 11.4 11.8 12.3
MYSQL_VERSIONS ?= 9.7
VALKEY_VERSIONS ?= 9.0.4 9.1.1
REDIS_VERSIONS ?= 8.10.0
MAILPIT_VERSIONS ?= 1.30
VICTORIA_LOGS_VERSIONS ?= 1.52.0
VMAUTH_VERSION ?= 1.148.0
ALPINE_VERSION ?= 3.20
CADDY_VERSION ?= 2.11.4
FRANKENPHP_VERSION ?= 1.12.6

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
export CADDY_VERSION
export FRANKENPHP_VERSION
export BUILD_DATE
export UBUNTU_VERSIONS := $(subst $(space),$(comma),$(UBUNTU_VERSIONS))
export PHP_VERSIONS := $(subst $(space),$(comma),$(PHP_VERSIONS))
export FRANKENPHP_VERSIONS := $(subst $(space),$(comma),$(FRANKENPHP_VERSIONS))
export MARIADB_VERSIONS := $(subst $(space),$(comma),$(MARIADB_VERSIONS))
export MYSQL_VERSIONS := $(subst $(space),$(comma),$(MYSQL_VERSIONS))
export VALKEY_VERSIONS := $(subst $(space),$(comma),$(VALKEY_VERSIONS))
export REDIS_VERSIONS := $(subst $(space),$(comma),$(REDIS_VERSIONS))
export MAILPIT_VERSIONS := $(subst $(space),$(comma),$(MAILPIT_VERSIONS))
export VICTORIA_LOGS_VERSIONS := $(subst $(space),$(comma),$(VICTORIA_LOGS_VERSIONS))
export VMAUTH_VERSION
export ALPINE_VERSION

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
