ARG FRANKENPHP_VERSION=1.12.7
ARG PHP_VERSION=8.5
ARG SCRIPTLING_VERSION=v0.20.1
ARG GO_MODULE=example.com/frankenscriptling
ARG TAG_BASE=paularlott

# =============================================================================
# Stage 1: Build FrankenPHP with the Scriptling PHP extension
#          (same Caddy module set as knot-frankenphp, plus Scriptling)
# =============================================================================
FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-builder-php${PHP_VERSION} AS builder

COPY --from=caddy:builder /usr/bin/xcaddy /usr/bin/xcaddy

ARG FRANKENPHP_VERSION
ARG SCRIPTLING_VERSION
ARG GO_MODULE

WORKDIR /app

COPY scriptling_ext.go ./

RUN go mod init ${GO_MODULE} \
    && go get github.com/dunglas/frankenphp@v${FRANKENPHP_VERSION} \
    && go get github.com/paularlott/scriptling@${SCRIPTLING_VERSION}

# extension-init's stub generator needs gen_stub.php from the matching PHP source.
# Derive the exact patch version from the toolchain inside the builder image.
RUN PHP_FULL=$(php-config --version) \
    && curl -fsSL "https://www.php.net/distributions/php-${PHP_FULL}.tar.gz" -o /tmp/php.tar.gz \
    && tar xzf /tmp/php.tar.gz -C /tmp
RUN GEN_STUB_SCRIPT=/tmp/php-$(php-config --version)/build/gen_stub.php \
    frankenphp extension-init scriptling_ext.go

# FrankenPHP extension generator bug: when a class method returns int/float/bool,
# the generated C code casts the parameter from the return type instead of the
# parameter type. Undo the incorrect casts so parameters pass through unchanged.
RUN sed -i \
    -e 's/getVarInt_wrapper(intern->go_handle, (long)name)/getVarInt_wrapper(intern->go_handle, name)/g' \
    -e 's/getVarFloat_wrapper(intern->go_handle, (double)name)/getVarFloat_wrapper(intern->go_handle, name)/g' \
    -e 's/getVarBool_wrapper(intern->go_handle, (int)name)/getVarBool_wrapper(intern->go_handle, name)/g' \
    -e 's/hasVar_wrapper(intern->go_handle, (int)name)/hasVar_wrapper(intern->go_handle, name)/g' \
    scriptling_ext.c

# Same module set as knot-frankenphp (cloudflare, mercure, vulcain, cbrotli,
# transform-encoder), plus the Scriptling extension module.
RUN CGO_ENABLED=1 \
    XCADDY_GO_BUILD_FLAGS="-ldflags '-w -s' -tags nobadger,nomysql,nopgx" \
    CGO_CFLAGS="-D_GNU_SOURCE $(php-config --includes)" \
    CGO_LDFLAGS="$(php-config --ldflags) $(php-config --libs)" \
    xcaddy build \
        --output /usr/local/bin/frankenphp \
        --with github.com/dunglas/frankenphp/caddy@v${FRANKENPHP_VERSION} \
        --with github.com/dunglas/mercure/caddy@latest \
        --with github.com/dunglas/vulcain/caddy@latest \
        --with github.com/dunglas/caddy-cbrotli@latest \
        --with github.com/caddy-dns/cloudflare@latest \
        --with github.com/caddyserver/transform-encoder@latest \
        --with ${GO_MODULE}=/app

# =============================================================================
# Stage 2: Runtime — knot-frankenphp with the Scriptling-enabled binary
# =============================================================================
FROM ${TAG_BASE}/knot-frankenphp:${PHP_VERSION}

LABEL org.opencontainers.image.title="Knot FrankenScriptling"
LABEL org.opencontainers.image.description="FrankenPHP with the Scriptling PHP extension and the full knot toolchain"

COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp
