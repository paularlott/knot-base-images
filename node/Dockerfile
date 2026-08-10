ARG DOCKER_HUB=
ARG IMAGE_VERSION=26.04
ARG IMAGE_BASE=ubuntu
ARG TAG_BASE=paularlott
ARG NODE_MAJOR=24

FROM ${TAG_BASE}/knot-${IMAGE_BASE}:${IMAGE_VERSION}

ARG APT_CACHE
ARG NODE_MAJOR

ENV NODE_MAJOR=${NODE_MAJOR}

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get install -y ca-certificates gnupg2 \
  \
  # Node.js - latest ${NODE_MAJOR}.x from NodeSource (deb package)
  && curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - \
  && apt-get install -y nodejs \
  && node --version && npm --version \
  \
  # corepack - enables pnpm / yarn (not bundled with newer Node releases)
  && if command -v corepack >/dev/null 2>&1; then corepack enable; else npm install -g corepack && corepack enable; fi \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi
