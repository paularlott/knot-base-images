# Include optional .env file
-include .env

default: all

.PHONY: all
## Build the everything
all: knot-base-debian knot-base-ubuntu`

.PHONEY: knot-base-debian
## Build the docker image and push to GitHub for debian
knot-base-debian:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag ghcr.io/paularlott/knot-base-debian:bookworm \
		--build-arg IMAGE_VERSION=bookworm \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--push \
		./debian

.PHONEY: knot-base-ubuntu
## Build the docker image and push to GitHub for debian
knot-base-ubuntu:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag ghcr.io/paularlott/knot-base-ubuntu:22.04 \
		--build-arg IMAGE_VERSION=22.04 \
		--build-arg DOCKER_HUB=$(DOCKER_HUB) \
		--push \
		./ubuntu

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
