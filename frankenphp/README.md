# knot-frankenphp

A **PHP** development image for [knot](https://getknot.dev/) spaces, based on [`knot-frankenphp-runtime`](https://hub.docker.com/r/paularlott/knot-frankenphp-runtime), which runs Caddy and PHP together in a single process. The runtime image carries the knot toolchain, the PHP runtime and the custom `xcaddy` module set (DNS-01, Mercure, Vulcain, brotli, log-transform); this image adds the development layer — ssh, git, editors, shells, `rsyslog` utilities, Composer, Node.js, mago and mutagen.

This is the single-process alternative to the `knot-php` image; serve any HTML or PHP file from `~/public_html` on port 80.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-frankenphp/tags) for the current list.

Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 8080:80 \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_USER=alice \
  -v knot_home:/home \
  paularlott/knot-frankenphp:8.5
```

Files in the mounted home's `public_html` are served at `http://localhost:8080`.

## How it works

The image is built in two stages:

1. **Builder** (in `knot-frankenphp-runtime`) — compiles FrankenPHP with `xcaddy`, adding [`caddy-dns/cloudflare`](https://github.com/caddy-dns/cloudflare), [`mercure`](https://github.com/dunglas/mercure), [`vulcain`](https://github.com/dunglas/vulcain), [`caddy-cbrotli`](https://github.com/dunglas/caddy-cbrotli) and [`transform-encoder`](https://github.com/caddyserver/transform-encoder).
2. **Runtime** — [`knot-frankenphp-runtime`](https://hub.docker.com/r/paularlott/knot-frankenphp-runtime) (official FrankenPHP image plus the knot entrypoint, extension set, `gosu`, locales, `rsyslog` and cron) plus the dev-tool layer: ssh, git, editors, shells, Node.js, Composer, mago and mutagen.

A startup hook (`/etc/knot-startup.d/01-startup-frankenphp`):

1. Installs `/etc/cron.d/container-crons` and starts `cron`.
2. Creates `~/public_html` if missing.
3. Starts **FrankenPHP** with the bundled `/etc/frankenphp/Caddyfile`, which serves `~/public_html` via `php_server`, logs to syslog, and runs the admin API on `127.0.0.1:2019`.

The runtime base is Debian and the entrypoint mirrors `knot-ubuntu` — it creates the `KNOT_USER`, optionally starts `sshd`, downloads and runs the knot agent when `KNOT_SERVER` is set, and runs startup hooks.

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

FrankenPHP is [MIT](https://github.com/dunglas/frankenphp/blob/main/LICENSE). This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
