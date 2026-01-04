# Include optional .env file
-include .env

TAG_BASE ?= paularlott
DEBIAN_VERSION ?= 12
UBUNTU_VERSION ?= 24.04
CADDY_VERSION ?= 2.10.2
BUILD_WITH ?= docker

BUILD_DATE ?= $(shell date -u +'%Y%m%d')

# Define build command based on BUILD_WITH variable
ifeq ($(BUILD_WITH),apple)
    BUILD_CMD = container build
    #PLATFORM_ARG = --platform linux/amd64,linux/arm64
	PLATFORM_ARG = --arch arm64 --arch amd64
    PUSH_ARG =
define DOCKERFILE_CONTEXT
-f $(1)/Dockerfile \
$(1)
endef
define TAG_AND_PUSH_IMAGES
@echo "Tagging and pushing images for Apple container build..."
@for tag in $(2); do \
	container image tag $(1) $$tag; \
done
@for tag in $(1) $(2); do \
	container image push $$tag; \
done
endef
else
    BUILD_CMD = docker buildx build
    PLATFORM_ARG = --platform linux/amd64,linux/arm64
    PUSH_ARG = --push
define DOCKERFILE_CONTEXT
$(1)
endef
define TAG_AND_PUSH_IMAGES
endef
endif

default: all

.PHONY: all
## Build the everything
all: knot-ubuntu \
	knot-caddy \
	knot-ubuntu-php-8.3 \
	knot-ubuntu-php-8.4 \
	knot-ubuntu-php-8.5 \
	knot-ubuntu-desktop \
	knot-valkey-9.0.1 \
	knot-mariadb-10.11 \
	knot-mariadb-11.4 \
	knot-mariadb-11.8

# knot-debian knot-debian-php-8.3 knot-debian-php-8.4
# knot-debian-desktop knot-redis-7.2

# .PHONEY: knot-debian
# ## Build a base debian image and push to github, includes start up scripts and code-server
# knot-debian:
# 	docker buildx build \
# 		--platform linux/amd64,linux/arm64 \
# 		--tag $(TAG_BASE)/knot-debian:$(DEBIAN_VERSION) \
# 		--tag $(TAG_BASE)/knot-debian:$(DEBIAN_VERSION)-$(BUILD_DATE) \
# 		--tag $(TAG_BASE)/knot-debian:latest \
# 		--build-arg IMAGE_BASE=debian \
# 		--build-arg IMAGE_VERSION=$(DEBIAN_VERSION) \
# 		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
# 		--build-arg APT_CACHE=$(APT_CACHE) \
# 		--build-arg TAG_BASE=$(TAG_BASE) \
# 		--push \
# 		./base

.PHONEY: knot-ubuntu
## Build a base ubuntu image and push to github, includes start up scripts and code-server
knot-ubuntu:
	$(BUILD_CMD) \
		$(PLATFORM_ARG) \
		--tag $(TAG_BASE)/knot-ubuntu:$(UBUNTU_VERSION)-$(BUILD_DATE) \
		--tag $(TAG_BASE)/knot-ubuntu:$(UBUNTU_VERSION) \
		--build-arg IMAGE_BASE=ubuntu \
		--build-arg IMAGE_VERSION=$(UBUNTU_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		$(PUSH_ARG) \
		$(call DOCKERFILE_CONTEXT,./base)
	$(call TAG_AND_PUSH_IMAGES,$(TAG_BASE)/knot-ubuntu:$(UBUNTU_VERSION),$(TAG_BASE)/knot-ubuntu:$(UBUNTU_VERSION)-$(BUILD_DATE))

# .PHONEY: knot-debian-desktop
# ## Build a base debian image and push to github, includes start up scripts, code-server and xfce
# knot-debian-desktop: knot-debian
# 	docker buildx build \
# 		--platform linux/amd64,linux/arm64 \
# 		--tag $(TAG_BASE)/knot-desktop:debian-$(DEBIAN_VERSION) \
# 		--build-arg IMAGE_BASE=debian \
# 		--build-arg IMAGE_VERSION=$(DEBIAN_VERSION) \
# 		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
# 		--build-arg APT_CACHE=$(APT_CACHE) \
# 		--build-arg TAG_BASE=$(TAG_BASE) \
# 		--push \
# 		./desktop

.PHONEY: knot-ubuntu-desktop
## Build a base ubuntu image and push to github, includes start up scripts, code-server and xfce
knot-ubuntu-desktop:
	$(BUILD_CMD) \
		$(PLATFORM_ARG) \
		--tag $(TAG_BASE)/knot-desktop:$(UBUNTU_VERSION)-$(BUILD_DATE) \
		--tag $(TAG_BASE)/knot-desktop:$(UBUNTU_VERSION) \
		--build-arg IMAGE_BASE=ubuntu \
		--build-arg IMAGE_VERSION=$(UBUNTU_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		$(PUSH_ARG) \
		$(call DOCKERFILE_CONTEXT,./desktop)
	$(call TAG_AND_PUSH_IMAGES,$(TAG_BASE)/knot-desktop:$(UBUNTU_VERSION),$(TAG_BASE)/knot-desktop:$(UBUNTU_VERSION)-$(BUILD_DATE))

.PHONEY: knot-caddy
## Build a caddy image used for the PHP containers
knot-caddy:
	$(BUILD_CMD) \
		$(PLATFORM_ARG) \
		--tag $(TAG_BASE)/knot-caddy:$(CADDY_VERSION)-$(BUILD_DATE) \
		--tag $(TAG_BASE)/knot-caddy:$(CADDY_VERSION) \
		--build-arg IMAGE_VERSION=$(CADDY_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		$(PUSH_ARG) \
		$(call DOCKERFILE_CONTEXT,./caddy)
	$(call TAG_AND_PUSH_IMAGES,$(TAG_BASE)/knot-caddy:$(CADDY_VERSION),$(TAG_BASE)/knot-caddy:$(CADDY_VERSION)-$(BUILD_DATE) $(TAG_BASE)/knot-caddy:latest)

# .PHONEY: knot-debian-php-%
# ## Build a debian image with caddy and PHP
# knot-debian-php-%: knot-debian
# 	docker buildx build \
# 		--platform linux/amd64,linux/arm64 \
# 		--tag $(TAG_BASE)/knot-php:$*-debian$(DEBIAN_VERSION) \
# 		--build-arg IMAGE_BASE=debian \
# 		--build-arg IMAGE_VERSION=$(DEBIAN_VERSION) \
# 		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
# 		--build-arg APT_CACHE=$(APT_CACHE) \
# 		--build-arg TAG_BASE=$(TAG_BASE) \
# 		--build-arg PHP_VERSION=$* \
# 		--push \
# 		./php

.PHONEY: knot-ubuntu-php-%
## Build an ubuntu image with caddy and PHP
knot-ubuntu-php-%:
	$(BUILD_CMD) \
		$(PLATFORM_ARG) \
		--tag $(TAG_BASE)/knot-php:$*-$(BUILD_DATE) \
		--tag $(TAG_BASE)/knot-php:$* \
		--build-arg IMAGE_BASE=ubuntu \
		--build-arg IMAGE_VERSION=$(UBUNTU_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--build-arg PHP_VERSION=$* \
		$(PUSH_ARG) \
		$(call DOCKERFILE_CONTEXT,./php)
    $(call TAG_AND_PUSH_IMAGES,$(TAG_BASE)/knot-php:$*,$(TAG_BASE)/knot-php:$*-$(BUILD_DATE))

.PHONEY: knot-mariadb-%
## Build a mariadb image
knot-mariadb-%:
	$(BUILD_CMD) \
		$(PLATFORM_ARG) \
		--tag $(TAG_BASE)/knot-mariadb:$*-$(BUILD_DATE) \
		--tag $(TAG_BASE)/knot-mariadb:$* \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--build-arg MARIADB_VERSION=$* \
		$(PUSH_ARG) \
		$(call DOCKERFILE_CONTEXT,./mariadb)
	$(call TAG_AND_PUSH_IMAGES,$(TAG_BASE)/knot-mariadb:$*,$(TAG_BASE)/knot-mariadb:$*-$(BUILD_DATE))

# .PHONEY: knot-redis-%
# ## Build a redis image
# knot-redis-%:
# 	docker buildx build \
# 		--platform linux/amd64,linux/arm64 \
# 		--tag $(TAG_BASE)/knot-redis:$* \
# 		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
# 		--build-arg APT_CACHE=$(APT_CACHE) \
# 		--build-arg TAG_BASE=$(TAG_BASE) \
# 		--build-arg REDIS_VERSION=$* \
# 		--push \
# 		./redis

.PHONEY: knot-valkey-%
## Build a redis image
knot-valkey-%:
	$(BUILD_CMD) \
		$(PLATFORM_ARG) \
		--tag $(TAG_BASE)/knot-valkey:$*-$(BUILD_DATE) \
		--tag $(TAG_BASE)/knot-valkey:$* \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--build-arg VALKEY_VERSION=$* \
		$(PUSH_ARG) \
		$(call DOCKERFILE_CONTEXT,./valkey)
	$(call TAG_AND_PUSH_IMAGES,$(TAG_BASE)/knot-valkey:$*,$(TAG_BASE)/knot-valkey:$*-$(BUILD_DATE))

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
	@printf "\n"
