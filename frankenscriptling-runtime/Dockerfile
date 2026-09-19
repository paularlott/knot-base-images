ARG FRANKENSCRIPTLING_REGISTRY=paularlott
ARG FRANKENSCRIPTLING_TAG=0.25.2-php8.5
ARG PHP_VERSION=8.5
ARG TAG_BASE=paularlott

# =============================================================================
# The scriptling+FrankenPHP binary itself is built and published by the
# standalone paularlott/frankenscriptling repo (which also carries the
# security-policy gating for scriptling's fs/net-capable libraries) — this
# just pulls it. FRANKENSCRIPTLING_REGISTRY defaults to Docker Hub but can
# point at a local registry (e.g. localhost:5000/paularlott) for a fast
# inner dev loop against an unpublished build.
# =============================================================================
FROM ${FRANKENSCRIPTLING_REGISTRY}/frankenscriptling:${FRANKENSCRIPTLING_TAG} AS scriptling-binary

# =============================================================================
# Runtime — knot-frankenphp-runtime with the Scriptling-enabled binary,
# no dev tools. knot-frankenscriptling (the dev image) builds on this.
# =============================================================================
FROM ${TAG_BASE}/knot-frankenphp-runtime:${PHP_VERSION}

LABEL org.opencontainers.image.title="Knot FrankenScriptling Runtime"
LABEL org.opencontainers.image.description="FrankenPHP runtime with the Scriptling PHP extension, no dev tools"

COPY --from=scriptling-binary /usr/local/bin/frankenphp /usr/local/bin/frankenphp
