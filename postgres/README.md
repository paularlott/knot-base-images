# knot-postgres

A [PostgreSQL](https://www.postgresql.org/) image for [knot](https://getknot.dev/) spaces. It wraps the official `postgres` image with the knot entrypoint, so a PostgreSQL instance running inside a space gets the same agent integration, `rsyslog` logging and startup hooks as every other knot base image. It is otherwise a standard PostgreSQL container and accepts the usual PostgreSQL environment variables.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-postgres/tags) for the current list.

Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=changeme \
  -e KNOT_SERVER=https://knot.example.com \
  -v pg_data:/var/lib/postgresql/data \
  paularlott/knot-postgres:18
```

In a knot space, the password is typically set from the user's **Service Password**:

```yaml
environment:
  - KNOT_SERVER=${{.server.url}}
  - KNOT_USER=postgres
  - POSTGRES_PASSWORD=${{.user.service_password}}
```

Connect to the running server (from the host or another space) via knot port forwarding:

```bash
knot forward port 127.0.0.1:5432 <space> 5432
```

## How it works

The image layers the knot entrypoint on top of the official PostgreSQL image. On startup the entrypoint:

1. Forwards `KNOT_USER` to `postgres`.
2. If `KNOT_SERVER` is set, downloads and starts the **knot agent** (as `postgres`).
3. Starts `rsyslog` and forwards logs to the agent's syslog port.
4. Runs scripts in `/etc/knot-startup.d/` and `~/.knot-startup.d/`.
5. `exec`s PostgreSQL's original [`docker-entrypoint.sh`](https://github.com/docker-library/postgres) with `postgres`.

### PostgreSQL customizations

- **Home directory** — the `postgres` user's home is relocated from `/var/lib/postgresql` (the data directory) to `/home/postgres`, so the knot agent's state and user startup hooks live under `/home/postgres/.knot` and `~/.knot-startup.d/` instead of colliding with database files.
- **Logging** — PostgreSQL's error log is captured by piping the server's stderr to `rsyslog` (tag `postgres`).

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `postgres` | Runtime user (forced) |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone |

Plus all standard PostgreSQL variables (`POSTGRES_PASSWORD`, `POSTGRES_USER`, `POSTGRES_DB`, `POSTGRES_INITDB_ARGS`, …) and config mounted under `$PGDATA` (default `/var/lib/postgresql/data`).

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5432` | TCP | PostgreSQL |

## Volumes

- **`/var/lib/postgresql/data`** — the PostgreSQL data directory (`PGDATA`); persist this across restarts.

## License

PostgreSQL is [PostgreSQL License](https://www.postgresql.org/about/licence/) (similar to BSD/MIT). This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
