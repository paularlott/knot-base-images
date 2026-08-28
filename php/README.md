# knot-php

A **PHP** development image for [knot](https://getknot.dev/) spaces, combining `knot-ubuntu` with [PHP-FPM](https://www.php.net/manual/en/install.fpm.php) and a [Caddy](https://caddyserver.com/) web server (the binary from `knot-caddy`). Any HTML or PHP file placed in `~/public_html` is served on port 80, with PHP executed via FastCGI. [Composer](https://getcomposer.org/) and [Node.js](https://nodejs.org/) are preinstalled for front-end / asset work.

It inherits the full knot entrypoint, runtime user, `rsyslog` logging and startup-hook framework from `knot-ubuntu`.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-php/tags) for the current list.

PHP is installed from the [Ondřej Surý PPA](https://packages.sury.org/php/). Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 8080:80 \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_USER=alice \
  -v knot_home:/home \
  paularlott/knot-php:8.5
```

Place files in the mounted home's `public_html` directory and open `http://localhost:8080`.

## How it works

A startup hook (`/etc/knot-startup.d/01-startup-php`) starts:

1. **`cron`** with `/etc/cron.d/container-crons` (which rotates logs every 4 hours).
2. **`php-fpm`** listening on the Unix socket `/run/php/php-fpm.sock` (logging to syslog).
3. Creates `~/public_html` if missing.
4. **Caddy** on `:80` with the bundled `/etc/caddy/Caddyfile`, which:
   - serves `~/public_html` with the static file server + directory browser,
   - enables `zstd` / `gzip` compression,
   - proxies `*.php` to the php-fpm socket via `php_fastcgi`,
   - writes access logs to syslog.

> Prefer a single Caddy+PHP process? See the `knot-frankenphp` image.

### Preinstalled PHP extensions

`gd`, `pdo`, `pdo-mysql`, `mysqli`, `bcmath`, `mbstring`, `exif`, `zip`, `sockets`, `iconv`, `gettext`, `curl`, `redis`, `mailparse`, `xml`, `dev`, `pear`, plus `opcache` (PHP 8.4). Also bundled:

- **[Xdebug](https://xdebug.org/)** — toggled with the `phpenxdebug` / `phpdisxdebug` helper scripts.
- **[php-spx](https://github.com/NoiseByNorthwest/php-spx)** — a low-overhead sampling profiler.

## Environment variables

Built on `knot-ubuntu`, so it supports the common knot variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `knot` | Runtime user (uid `1000`); created if missing |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is downloaded and started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SERVICE_PASSWORD` | _(auto-generated UUID)_ | Shared service password |
| `KNOT_SSHD` | _(unset)_ | Set to `native` to start `sshd` |
| `KNOT_SSH_PORT` | `2222` | Port for the SSH daemon |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone (also sets `date.timezone`) |

PHP-specific:

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_VERSION` | _(build-time)_ | The PHP version, also used to locate `/etc/php/<version>/` configs |

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `80` | TCP | HTTP (Caddy → php-fpm) |

## Volumes

- **`/home`** — persistent home directory; serve content from `~/public_html`.

## License

The Ubuntu base image, PHP, Caddy and their packages are licensed under their respective upstream licenses (PHP is PHP License; Caddy is Apache 2.0). This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
