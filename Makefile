# Include optional .env file
-include .env

TAG_BASE ?= paularlott
DEBIAN_VERSION ?= 12
UBUNTU_VERSION ?= 22.04

default: all

.PHONY: all
## Build the everything
all: knot-base-debian knot-base-ubuntu \
	knot-base-debian-desktop knot-base-ubuntu-desktop \
	knot-base-debian-php-8.2 knot-base-ubuntu-php-8.2 \
	knot-base-debian-php-8.3 knot-base-ubuntu-php-8.3

.PHONEY: knot-base-debian
## Build a base debian image and push to github, includes start up scripts and code-server
knot-base-debian:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-base-debian:$(DEBIAN_VERSION) \
		--build-arg IMAGE_BASE=debian \
		--build-arg IMAGE_VERSION=$(DEBIAN_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--push \
		./base

.PHONEY: knot-base-ubuntu
## Build a base ubuntu image and push to github, includes start up scripts and code-server
knot-base-ubuntu:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-base-ubuntu:$(UBUNTU_VERSION) \
		--build-arg IMAGE_BASE=ubuntu \
		--build-arg IMAGE_VERSION=$(UBUNTU_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--push \
		./base

.PHONEY: knot-base-debian-desktop
## Build a base debian image and push to github, includes start up scripts, code-server and xfce
knot-base-debian-desktop:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-base-debian-desktop:$(DEBIAN_VERSION) \
		--build-arg IMAGE_BASE=debian \
		--build-arg IMAGE_VERSION=$(DEBIAN_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--push \
		./desktop

.PHONEY: knot-base-ubuntu-desktop
## Build a base ubuntu image and push to github, includes start up scripts, code-server and xfce
knot-base-ubuntu-desktop:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-base-ubuntu-desktop:$(UBUNTU_VERSION) \
		--build-arg IMAGE_BASE=ubuntu \
		--build-arg IMAGE_VERSION=$(UBUNTU_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--push \
		./desktop


.PHONEY: knot-base-debian-php-%
## Build a debian image with caddy and PHP
knot-base-debian-php-%:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-base-debian-php:$* \
		--build-arg IMAGE_BASE=debian \
		--build-arg IMAGE_VERSION=$(DEBIAN_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--build-arg PHP_VERSION=$* \
		--push \
		./php

.PHONEY: knot-base-ubuntu-php-%
## Build an ubuntu image with caddy and PHP
knot-base-ubuntu-php-%:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-base-ubuntu-php:$* \
		--build-arg IMAGE_BASE=ubuntu \
		--build-arg IMAGE_VERSION=$(UBUNTU_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--build-arg PHP_VERSION=$* \
		--push \
		./php

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
