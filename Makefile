# Include optional .env file
-include .env

default: all

.PHONY: all
## Build the everything
all: knot-base-debian knot-base-ubuntu

.PHONEY: knot-base-debian
## Build a base debian image and push to github, includes start up scripts and code-server
knot-base-debian:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag paularlott/knot-base-debian:12 \
		--build-arg IMAGE_BASE=debian \
		--build-arg IMAGE_VERSION=12 \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--push \
		./base

.PHONEY: knot-base-ubuntu
## Build a base ubuntu image and push to github, includes start up scripts and code-server
knot-base-ubuntu:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag paularlott/knot-base-ubuntu:22.04 \
		--build-arg IMAGE_BASE=ubuntu \
		--build-arg IMAGE_VERSION=22.04 \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--push \
		./base

.PHONEY: knot-base-debian-desktop
## Build a base debian image and push to github, includes start up scripts, code-server and xfce
knot-base-debian-desktop:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag paularlott/knot-base-debian-desktop:12 \
		--build-arg IMAGE_BASE=debian \
		--build-arg IMAGE_VERSION=12 \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--push \
		./desktop

.PHONEY: knot-base-ubuntu-desktop
## Build a base ubuntu image and push to github, includes start up scripts, code-server and xfce
knot-base-ubuntu-desktop:
	docker buildx build \
		--platform linux/arm64 \
		--tag paularlott/knot-base-ubuntu-desktop:22.04 \
		--build-arg IMAGE_BASE=ubuntu \
		--build-arg IMAGE_VERSION=22.04 \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--build-arg APT_CACHE=$(APT_CACHE) \
		--load \
		./desktop

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
