# knot-mysql

A [MySQL](https://www.mysql.com/) image for [knot](https://getknot.dev/) spaces. It wraps the official `mysql` image with the knot entrypoint, so a MySQL instance running inside a space gets the same agent integration, `rsyslog` logging and startup hooks as every other knot base image. It is otherwise a standard MySQL container and accepts the usual MySQL environment variables.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-mysql/tags) for the current list.

Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=changeme \
  -e KNOT_SERVER=https://knot.example.com \
  -v mysql_data:/var/lib/mysql \
  paularlott/knot-mysql:9.7
```

In a knot space, the root password is typically set from the user's **Service Password**:

```yaml
environment:
  - KNOT_SERVER=${{.server.url}}
  - KNOT_USER=mysql
  - MYSQL_ROOT_PASSWORD=${{.user.service_password}}
```

Connect to the running server (from the host or another space) via knot port forwarding:

```bash
knot forward port 127.0.0.1:3306 <space> 3306
```

## How it works

The image layers the knot entrypoint on top of the official MySQL image. On startup the entrypoint:

1. Forwards `KNOT_USER` to `mysql`.
2. If `KNOT_SERVER` is set, downloads and starts the **knot agent** (as `mysql`).
3. Starts `rsyslog` and forwards logs to the agent's syslog port.
4. Runs scripts in `/etc/knot-startup.d/` and `~/.knot-startup.d/`.
5. `exec`s MySQL's original [`docker-entrypoint.sh`](https://github.com/docker-library/mysql) with `mysqld`.

### MySQL customizations

- **Home directory** — the `mysql` user's home is relocated from `/var/lib/mysql` (the data directory) to `/home/mysql`, so the knot agent's state and user startup hooks live under `/home/mysql/.knot` and `~/.knot-startup.d/` instead of colliding with database files.
- **Local root access** — `/docker-entrypoint-initdb.d/localaccess.sql` clears the `root@localhost` password on first initialisation so that `mysqladmin ping` works for health checks.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `mysql` | Runtime user (forced) |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone |

Plus all standard MySQL variables (`MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, …) and MySQL config files mounted under `/etc/mysql/`.

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3306` | TCP | MySQL |

## Volumes

- **`/var/lib/mysql`** — the MySQL data directory; persist this across restarts.

## License

MySQL is [GPLv2 with FOSS Exception](https://www.mysql.com/about/legal/licensing/oem/). This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
