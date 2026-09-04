ARG TAG_BASE=paularlott
ARG ALPINE_VERSION=3.24
ARG SCRIPTLING_VERSION=v0.24.0

# =============================================================================
# knot-scriptling-runtime: knot-alpine-runtime with the Scriptling interpreter
# added — no dev tools. knot-scriptling (the dev image) builds on the dev-ful
# knot-ubuntu / knot-alpine bases instead.
# =============================================================================
FROM ${TAG_BASE}/knot-alpine-runtime:${ALPINE_VERSION}

ARG SCRIPTLING_VERSION

ENV SCRIPTLING_VERSION=${SCRIPTLING_VERSION}

# Scriptling is a static binary (works on musl) - download the release for
# this architecture and install it into /usr/local/bin.
RUN ARCH=$(uname -m); \
    case "$ARCH" in \
      'x86_64')  slarch="amd64";; \
      'aarch64') slarch="arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/paularlott/scriptling/releases/download/${SCRIPTLING_VERSION}/scriptling-linux-${slarch}.zip" -o /tmp/scriptling.zip \
    && unzip -q /tmp/scriptling.zip -d /tmp/scriptling \
    && install -m 0755 /tmp/scriptling/scriptling /usr/local/bin/scriptling \
    && rm -rf /tmp/scriptling /tmp/scriptling.zip \
    && scriptling --version

EXPOSE 8080

# Serve the Scriptling HTTP server by default so the container has a
# long-running process without an explicit command. MCP exec (--mcp-exec-script)
# is deliberately not enabled by default — it executes code sent to the server,
# so pair it with --bearer-token if you opt in.
CMD ["scriptling", "--server", "0.0.0.0:8080"]
