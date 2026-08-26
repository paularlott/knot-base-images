# knot-adminer

[Adminer](https://www.adminer.org/) database management on top of [`knot-frankenphp-runtime`](https://hub.docker.com/r/paularlott/knot-frankenphp-runtime) 8.5. Adminer is served by FrankenPHP from a fixed docroot (`/var/www/html`) instead of the user's `public_html`, so the image works as a drop-in database UI container while keeping the knot toolchain — entrypoint, agent integration, `rsyslog` logging and startup hooks, but none of the dev-image tooling (no sshd, git, editors, node or composer).

Supported database backends:

- **MySQL / MariaDB** — via `mysqli`/`pdo_mysql` (bundled in the base image)
- **PostgreSQL** — via `pgsql`/`pdo_pgsql`
- **Redis / Valkey** — via the Adminer Redis driver plugin (raw RESP protocol over sockets, no PHP extension required)
- SQLite, MS SQL and Oracle are also available in the all-driver Adminer build

## How it builds

`FROM` the published `knot-frankenphp-runtime:8.5` image, then:

1. Downloads the official all-driver `adminer-<version>.php` release as `/var/www/html/index.php`.
2. Copies the plugins (see below) and the `adminer.css` theme into the docroot — Adminer 6 auto-loads both `adminer-plugins/` and `adminer.css` when present.
3. Replaces `/etc/frankenphp/Caddyfile` with one rooted at `/var/www/html`, so the container serves Adminer on port 80.
4. Sets `CMD ["adminer-server"]` — unlike `knot-frankenphp` (which backgrounds Caddy and stays alive via the knot agent), this image runs FrankenPHP in the foreground as the main process, so the container works standalone. The bundled `01-startup-frankenphp` startup script is replaced accordingly (cron still starts; Caddy is not double-started).

Bundled plugins (loaded via `adminer-plugins.php`):

| Plugin | Purpose |
|--------|---------|
| `redis.php` | Official Adminer Redis driver (v6.0.1) with the JUSH syntax-highlighting module inlined for single-file installs |
| `srvlookup.php` | Resolves database hosts via DNS SRV records |
| `FasterTablesFilter.php` | Client-side table filter for databases with very many tables |
| `dark-switcher.php` | Official dark-mode switcher, adapted to the bundled theme: defaults to dark, remembers the choice in localStorage, toggle sits next to the logout block |

`adminer.css` is a custom theme (system fonts, indigo accent, no external assets) with light and dark palettes; Adminer auto-loads it, and sticky table headers come from Adminer 6's built-in CSS.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-adminer/tags) for the current list. The current release is also tagged `latest` and `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 8080:80 \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_USER=alice \
  paularlott/knot-adminer:latest
```

Open `http://localhost:8080`, pick a driver (MySQL, PostgreSQL, Redis, …), and connect.

## Environment variables

The entrypoint mirrors `knot-ubuntu`, so it supports the common knot variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `knot` | Runtime user (uid `1000`); created if missing |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is downloaded and started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SERVICE_PASSWORD` | _(auto-generated UUID)_ | Shared service password |
| `KNOT_SSHD` | _(unset)_ | Set to `native` to start `sshd` (not installed in this image; use `knot-frankenphp` if ssh is needed) |
| `KNOT_SSH_PORT` | `2222` | Port for the SSH daemon |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone |

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `80` | TCP | HTTP (Adminer via FrankenPHP) |
| `443` | TCP/UDP | HTTPS / HTTP-3 (when enabled) |
| `2019` | TCP | Caddy admin API |

## License

Adminer is licensed under [Apache License 2.0 / GPL 2.0](https://www.adminer.org/en/license/) — see [vrana/adminer](https://github.com/vrana/adminer). The bundled plugins retain their respective licences (linked in each file). This image's packaging is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
