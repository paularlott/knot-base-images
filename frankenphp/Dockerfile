ARG DOCKER_HUB=
ARG IMAGE_VERSION=latest
ARG IMAGE_BASE=ubuntu
ARG TAG_BASE=paularlott

FROM ${TAG_BASE}/knot-${IMAGE_BASE}:${IMAGE_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

ARG APT_CACHE
ARG PHP_VERSION
ARG NODEJS_VERSION=20.x
ENV PHP_VERSION=${PHP_VERSION}

# Map PHP_VERSION (e.g. 8.4, 8.5) to the deb repo version code (84, 85)
RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  \
  # Determine deb repo version (strip the dot from PHP_VERSION)
  && DEB_VERSION=$(echo "${PHP_VERSION}" | tr -d '.') \
  \
  # Add FrankenPHP / static-php deb repository
  && curl -sSL "https://pkg.henderkes.com/api/packages/${DEB_VERSION}/debian/repository.key" \
       -o /etc/apt/keyrings/static-php${DEB_VERSION}.asc \
  && echo "deb [signed-by=/etc/apt/keyrings/static-php${DEB_VERSION}.asc] https://pkg.henderkes.com/api/packages/${DEB_VERSION}/debian php-zts main" \
       > /etc/apt/sources.list.d/static-php${DEB_VERSION}.list \
  \
  # Install FrankenPHP and PHP extensions
  && apt-get update -y \
  && apt-get install -y \
    frankenphp \
    php-zts-gd \
    php-zts-pdo \
    php-zts-pdo-mysql \
    php-zts-bcmath \
    php-zts-mbstring \
    php-zts-exif \
    php-zts-zip \
    php-zts-sockets \
    php-zts-mysqli \
    php-zts-iconv \
    php-zts-gettext \
    php-zts-curl \
    php-zts-redis \
    php-zts-xml \
    php-zts-xdebug \
  \
  # Composer
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  \
  # Node.js
  && curl -fsSL https://deb.nodesource.com/setup_${NODEJS_VERSION} | bash - \
  && apt-get install -y nodejs \
  \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi

COPY files/knot-startup.d/ /etc/knot-startup.d/

COPY files/caddy/Caddyfile /etc/frankenphp/Caddyfile

COPY files/php-conf/custom.ini /etc/php-zts/conf.d/99-custom.ini

COPY files/misc/container-crons /etc/cron.d/container-crons
