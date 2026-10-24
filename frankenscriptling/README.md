# knot-frankenscriptling

A **PHP** development image for [knot](https://getknot.dev/) spaces: [FrankenPHP](https://frankenphp.dev/) with the [Scriptling](https://github.com/paularlott/scriptling) PHP extension, the knot toolchain and the full knot dev layer — ssh, git, editors, shells, Composer, Node.js, mago and mutagen. FrankenPHP carries the usual Caddy module set (DNS-01, Mercure, Vulcain, brotli, log-transform).

It is built on [`paularlott/frankenscriptling`](https://hub.docker.com/r/paularlott/frankenscriptling) (FrankenPHP + Scriptling), with the same knot runtime and dev layers as [`knot-frankenphp`](https://hub.docker.com/r/paularlott/knot-frankenphp); [`knot-frankenscriptling-runtime`](https://hub.docker.com/r/paularlott/knot-frankenscriptling-runtime) is the same without the dev layer. Because it starts from frankenscriptling rather than swapping a binary into `knot-frankenphp`, the Scriptling-enabled FrankenPHP and the PHP it runs always come from the same release.

The Scriptling extension exposes the [`Scriptling`](https://github.com/paularlott/scriptling) class to PHP, so applications can embed the Scriptling scripting/agent runtime directly:

```php
$vm = new Scriptling();
$vm->setVar('name', 'world');
echo $vm->eval('name');           // -> "world"
echo $vm->getScriptlingVersion(); // e.g. 0.33.0
```

The class stays available across FrankenPHP config reloads (admin API `/load`, `--watch`).

Serve any HTML or PHP file from `~/public_html` on port 80, exactly like `knot-frankenphp`.

## PHP extensions

The image ships with bcmath, exif, gd, gettext, mailparse, mysqli, opcache, pdo_mysql, pdo_pgsql, pgsql, redis, sockets, spx and zip, plus xdebug (installed, off by default).

The PHP build toolchain (`$PHPIZE_DEPS`: gcc, make, autoconf, …) is included, so extensions can be added the usual ways and the compilers stay in place afterwards:

```bash
sudo install-php-extensions intl imagick
sudo docker-php-ext-install calendar
sudo pecl install apcu
```

The toolchain is the main difference from [`knot-frankenscriptling-runtime`](https://hub.docker.com/r/paularlott/knot-frankenscriptling-runtime), which leaves it out to stay small (about 720MB) and brings it in only while `install-php-extensions` / `docker-php-ext-*` build an extension.

## Tags

One image per PHP line, e.g. `8.5`, built on the newest frankenscriptling release for that line. All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-frankenscriptling/tags) for the current list. Each build is also tagged `<php>-<BUILD_DATE>`, e.g. `8.5-20261024`.

## Usage

```bash
docker run -d \
  -p 8080:80 \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_USER=alice \
  -v knot_home:/home \
  paularlott/knot-frankenscriptling:8.5
```

## Environment variables

The entrypoint mirrors `knot-ubuntu`, so it supports the common knot variables:

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

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `80` | TCP | HTTP (FrankenPHP) |
| `443` | TCP/UDP | HTTPS / HTTP/3 (when enabled) |
| `2019` | TCP | Caddy admin API |

## Volumes

- **`/home`** — persistent home directory; serve content from `~/public_html`.

## License

FrankenPHP is [MIT](https://github.com/php/frankenphp/blob/main/LICENSE). Scriptling retains its own licence — see [paularlott/scriptling](https://github.com/paularlott/scriptling). This image's packaging is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images) (built from `frankenphp-runtime/` and `frankenphp/` on `paularlott/frankenscriptling`).
