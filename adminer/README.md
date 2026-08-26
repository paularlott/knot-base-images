# knot-adminer

[Adminer](https://www.adminer.org/) database management on top of [`knot-frankenphp-runtime`](https://hub.docker.com/r/paularlott/knot-frankenphp-runtime) 8.5. It manages MySQL/MariaDB, PostgreSQL and Redis (plus the other bundled Adminer drivers), serves Adminer from a fixed docroot on port 80, and runs FrankenPHP in the foreground so the container works standalone. It keeps the knot toolchain — entrypoint, agent integration, `rsyslog` logging and startup hooks — but none of the dev-image tooling (no sshd, git, editors, node or composer).

Bundled extras: the official Adminer Redis driver, DNS SRV hostname lookups, a fast client-side table filter, and a dark-capable theme (defaults to dark, toggle next to the logout block).

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

## Volumes

- **`/home`** — persistent home directory.

## License

Adminer is licensed under [Apache License 2.0 / GPL 2.0](https://www.adminer.org/en/license/) — see [vrana/adminer](https://github.com/vrana/adminer). The bundled plugins retain their respective licences (linked in each file). This image's packaging is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
