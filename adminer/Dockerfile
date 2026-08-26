# Source https://github.com/vrana/adminer
ARG TAG_BASE=paularlott
ARG PHP_VERSION=8.5
ARG ADMINER_VERSION=6.0.1

FROM ${TAG_BASE}/knot-frankenphp-runtime:${PHP_VERSION}

ARG ADMINER_VERSION

WORKDIR /var/www/html

# Adminer — all-driver build (MySQL/MariaDB, PostgreSQL, SQLite, MS SQL, Oracle);
# Redis support is added below via the bundled plugin driver.
# NOTE: --chmod is required — files fetched by remote ADD default to 0600,
# unreadable by the non-root user FrankenPHP runs as.
ADD --chmod=0644 \
  https://github.com/vrana/adminer/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php \
  index.php

# Plugins + driver, auto-loaded by Adminer from adminer-plugins/ and adminer-plugins.php
COPY files/adminer-plugins/ adminer-plugins/
COPY files/adminer-plugins.php .
COPY files/adminer.css .

# Serve Adminer from a fixed docroot instead of the user's public_html
COPY files/caddy/Caddyfile /etc/frankenphp/Caddyfile

# Override the base startup script: cron still starts, but FrankenPHP is not
# backgrounded here because CMD runs it in the foreground as the main process.
COPY files/knot-startup.d/ /etc/knot-startup.d/
COPY files/bin/ /usr/local/bin/

CMD ["adminer-server"]
