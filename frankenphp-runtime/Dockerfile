ARG FRANKENPHP_VERSION=1.12.7
ARG PHP_VERSION=8.5
ARG APT_CACHE=

# =============================================================================
# Stage 1: Build FrankenPHP with custom Caddy modules
# =============================================================================
FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-builder-php${PHP_VERSION} AS builder

COPY --from=caddy:builder /usr/bin/xcaddy /usr/bin/xcaddy

ARG FRANKENPHP_VERSION

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
        --with github.com/caddyserver/transform-encoder@latest

# Build PHP extension: Xdebug
RUN pecl install xdebug \
    && mkdir -p /tmp/exts \
    && cp "$(php-config --extension-dir)/xdebug.so" /tmp/exts/

# =============================================================================
# Stage 2: Runtime — FrankenPHP with the knot toolchain but no dev tools.
# knot-frankenphp (the dev image) builds on this; appliances like knot-adminer
# use it directly.
# =============================================================================
FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION}

ARG APT_CACHE

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8 \
  TZ=Etc/UTC \
  TERM=xterm-256color \
  KNOT_SSH_PORT=2222 \
  KNOT_SYSLOG_PORT=1514

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get dist-upgrade -y \
  # Runtime essentials: what the knot entrypoint needs (curl+funzip for the
  # agent download, uuidgen, gosu, setcap, crontab, rsyslogd, logger), sudo
  # and the database CLI clients. No editors, shells, ssh or build tooling.
  && apt-get install -y \
    tzdata locales procps cron logrotate rsyslog sudo ssl-cert \
    curl unzip uuid-runtime libcap2-bin \
    mariadb-client postgresql-client \
  \
  # gosu - https://github.com/tianon/gosu/releases (latest)
  && DPKG_ARCH=$(dpkg --print-architecture); \
    curl -Lo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/latest/download/gosu-${DPKG_ARCH}"; \
    chmod +x /usr/local/bin/gosu \
  \
  # PHP extensions — mirror the module set from the knot-php image.
  # Base image already provides mbstring, curl, iconv, pdo, xml/dom, sodium,
  # sqlite, zlib and pear/pecl; xdebug is built in stage 1.
  && install-php-extensions \
    bcmath exif gd gettext mailparse mysqli opcache \
    pdo_mysql pdo_pgsql pgsql redis sockets spx zip \
  \
  # Locale
  && echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
  && dpkg-reconfigure --frontend=noninteractive locales \
  \
  # rsyslog for container
  && sed -i 's/^\(module(load="imklog".*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\$RepeatedMsgReduction on$/\$RepeatedMsgReduction off/' /etc/rsyslog.conf \
  && touch /etc/rsyslog.d/50-default.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.d/50-default.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.d/50-default.conf \
  \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi

# Replace the FrankenPHP binary with our custom build (includes transform-encoder etc.)
COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp

# PHP extension: Xdebug (built in stage 1)
COPY --from=builder /tmp/exts/ /tmp/exts/
RUN EXT_DIR=$(php-config --extension-dir) \
    && mv /tmp/exts/xdebug.so "$EXT_DIR/" \
    && rm -rf /tmp/exts

# Knot entrypoint and startup scripts
COPY files/bin/* /usr/local/bin/
COPY files/knot-startup.d/ /etc/knot-startup.d/
COPY files/caddy/Caddyfile /etc/frankenphp/Caddyfile
COPY files/misc/container-crons /etc/cron.d/container-crons

# PHP configuration: xdebug disabled by default
COPY files/php-mods/xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini.disabled

VOLUME /home

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
