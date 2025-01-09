ARG DOCKER_HUB=
ARG IMAGE_VERSION=latest
ARG IMAGE_BASE=ubuntu
ARG TAG_BASE=paularlott

FROM ${TAG_BASE}/knot-caddy:2.9.1 AS caddy

FROM ${TAG_BASE}/knot-${IMAGE_BASE}:${IMAGE_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

ARG APT_CACHE
ARG PHP_VERSION
ARG NODEJS_VERSION=20.x
ENV PHP_VERSION=${PHP_VERSION}

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  # PHP repository
  && OS=$(lsb_release -si); \
  if [ "$OS" = "Debian" ]; then \
		curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list; \
	elif [ "$OS" = "Ubuntu" ]; then \
		add-apt-repository -y ppa:ondrej/php; \
	else \
		echo "Unsupported OS"; exit 1 ; \
	fi \
  \
  # Install
  && apt-get update -y \
  && apt-get install -y dialog \
  && apt-get install -y \
    php${PHP_VERSION}-fpm php${PHP_VERSION}-cli \
    php${PHP_VERSION}-gd php${PHP_VERSION}-opcache php${PHP_VERSION}-pdo php${PHP_VERSION}-pdo-mysql php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-mbstring php${PHP_VERSION}-exif php${PHP_VERSION}-zip php${PHP_VERSION}-sockets php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-iconv php${PHP_VERSION}-gettext php${PHP_VERSION}-curl \
    php${PHP_VERSION}-redis php${PHP_VERSION}-mailparse \
    php${PHP_VERSION}-dev php${PHP_VERSION}-xml php-pear \
    libzip-dev \
  && mkdir -p /run/php/ \
  && chown -R www-data:www-data /run/php \
  && ln -fs /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm \
  \
  # xdebug
  && pecl install xdebug \
  \
  # Profiler
  && git clone https://github.com/NoiseByNorthwest/php-spx.git \
	&& cd php-spx \
	&& git checkout release/latest \
	&& phpize \
	&& ./configure \
	&& make -j 8 \
	&& make install \
	&& cd .. \
	&& rm -rf php-spx.github \
  && phpenmod php-spx \
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

COPY files/fpm-pool.d/* /etc/php/${PHP_VERSION}/fpm/pool.d/
COPY files/conf.d/* /etc/php/${PHP_VERSION}/fpm/conf.d/
COPY files/php-conf/* /etc/php/${PHP_VERSION}/cli/conf.d/
COPY files/php-conf/* /etc/php/${PHP_VERSION}/fpm/conf.d/
COPY files/php-mods/php-spx.ini /etc/php/${PHP_VERSION}/mods-available/php-spx.ini
COPY files/php-mods/xdebug.ini /etc/php/${PHP_VERSION}/mods-available/xdebug.ini
COPY files/bin/* /usr/local/bin/

COPY files/caddy/Caddyfile /etc/caddy/Caddyfile

COPY files/misc/container-crons /etc/cron.d/container-crons

# Caddy server
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY --from=caddy  /usr/share/caddy/index.html  /usr/share/caddy/index.html

RUN sed -i "s/8\.2/${PHP_VERSION}/g" /etc/php/${PHP_VERSION}/fpm/pool.d/docker.conf
