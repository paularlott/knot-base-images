# Include optional .env file
-include .env

TAG_BASE ?= paularlott
DEBIAN_VERSION ?= 12
UBUNTU_VERSION ?= 22.04

default: all

.PHONY: all
## Build the everything
all: knot-debian knot-ubuntu \
	knot-debian-php-8.2 knot-ubuntu-php-8.2 \
	knot-debian-php-8.3 knot-ubuntu-php-8.3 \
	knot-debian-desktop knot-ubuntu-desktop \
	knot-redis-7.2 \
	knot-mariadb-10.11 knot-mariadb-11.4

.PHONEY: knot-debian
## Build a base debian image and push to github, includes start up scripts and code-server
knot-debian:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-debian:$(DEBIAN_VERSION) \
		--build-arg IMAGE_BASE=debian \
		--build-arg IMAGE_VERSION=$(DEBIAN_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--push \
		./base

.PHONEY: knot-ubuntu
## Build a base ubuntu image and push to github, includes start up scripts and code-server
knot-ubuntu:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-ubuntu:$(UBUNTU_VERSION) \
		--build-arg IMAGE_BASE=ubuntu \
		--build-arg IMAGE_VERSION=$(UBUNTU_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--push \
		./base

.PHONEY: knot-debian-desktop
## Build a base debian image and push to github, includes start up scripts, code-server and xfce
knot-debian-desktop: knot-debian
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-desktop:debian-$(DEBIAN_VERSION) \
		--build-arg IMAGE_BASE=debian \
		--build-arg IMAGE_VERSION=$(DEBIAN_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--push \
		./desktop

.PHONEY: knot-ubuntu-desktop
## Build a base ubuntu image and push to github, includes start up scripts, code-server and xfce
knot-ubuntu-desktop: knot-ubuntu
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-desktop:ubuntu-$(UBUNTU_VERSION) \
		--build-arg IMAGE_BASE=ubuntu \
		--build-arg IMAGE_VERSION=$(UBUNTU_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--push \
		./desktop


.PHONEY: knot-debian-php-%
## Build a debian image with caddy and PHP
knot-debian-php-%: knot-debian
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-php:$*-debian \
		--build-arg IMAGE_BASE=debian \
		--build-arg IMAGE_VERSION=$(DEBIAN_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--build-arg PHP_VERSION=$* \
		--push \
		./php

.PHONEY: knot-ubuntu-php-%
## Build an ubuntu image with caddy and PHP
knot-ubuntu-php-%: knot-ubuntu
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-php:$*-ubuntu \
		--build-arg IMAGE_BASE=ubuntu \
		--build-arg IMAGE_VERSION=$(UBUNTU_VERSION) \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--build-arg PHP_VERSION=$* \
		--push \
		./php

.PHONEY: knot-mariadb-%
## Build a mariadb image
knot-mariadb-%:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-mariadb:$* \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--build-arg MARIADB_VERSION=$* \
		--push \
		./mariadb

.PHONEY: knot-redis-%
## Build a redis image
knot-redis-%:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(TAG_BASE)/knot-redis:$* \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--build-arg TAG_BASE=$(TAG_BASE) \
		--build-arg REDIS_VERSION=$* \
		--push \
		./redis

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
