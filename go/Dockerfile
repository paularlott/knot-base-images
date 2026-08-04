ARG DOCKER_HUB=
ARG IMAGE_VERSION=26.04
ARG IMAGE_BASE=ubuntu
ARG TAG_BASE=paularlott
ARG GO_VERSION=1.26

FROM ${TAG_BASE}/knot-${IMAGE_BASE}:${IMAGE_VERSION}

ARG APT_CACHE
ARG GO_VERSION

ENV GOROOT=/usr/local/go \
    GOPATH=/home/.go \
    PATH=/usr/local/go/bin:/home/.go/bin:$PATH

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get install -y gcc build-essential ca-certificates libarchive-tools \
  \
  # Go toolchain - latest ${GO_VERSION}.x from go.dev (multi-arch tarball).
  # bsdtar (libarchive) is used instead of GNU tar because GNU tar's use of
  # newer syscalls (openat2) fails with "Function not implemented" under
  # binfmt/qemu cross-architecture builds.
  && ARCH=$(uname -m); \
    case "$ARCH" in \
      'x86_64')  goarch="amd64";; \
      'aarch64') goarch="arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    GO_LATEST=$(curl -fsSL 'https://go.dev/dl/?mode=json' \
      | jq -r --arg prefix "go${GO_VERSION}." '[.[] | select(.stable and (.version | startswith($prefix)))] | .[0].version'); \
    echo "Installing ${GO_LATEST} for linux/${goarch}"; \
    curl -fsSL "https://go.dev/dl/${GO_LATEST}.linux-${goarch}.tar.gz" | bsdtar -xz -C /usr/local; \
    /usr/local/go/bin/go version \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi
