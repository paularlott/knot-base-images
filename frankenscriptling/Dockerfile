ARG TAG_BASE=paularlott
ARG PHP_VERSION=8.5

# =============================================================================
# knot-frankenscriptling: the knot-frankenphp dev image with its FrankenPHP
# binary replaced by the Scriptling-enabled build produced in
# knot-frankenscriptling-runtime. Everything else (dev tools, entrypoint,
# Caddyfile, startup hooks) is inherited unchanged from knot-frankenphp.
# =============================================================================
# COPY --from does not expand ARGs, so the runtime image is materialised as a
# stage first and the binary copied from there.
FROM ${TAG_BASE}/knot-frankenscriptling-runtime:${PHP_VERSION} AS scriptling-binary

FROM ${TAG_BASE}/knot-frankenphp:${PHP_VERSION}

LABEL org.opencontainers.image.title="Knot FrankenScriptling"
LABEL org.opencontainers.image.description="FrankenPHP with the Scriptling PHP extension and the full knot toolchain"

COPY --from=scriptling-binary /usr/local/bin/frankenphp /usr/local/bin/frankenphp
