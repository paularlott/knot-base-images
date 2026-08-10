# knot-redis

A [Redis 8](https://redis.io/) image for [knot](https://getknot.dev/) spaces. It wraps the official `redis` Alpine image with the knot entrypoint. A Redis instance running inside a space gets the same agent integration, `rsyslog` logging and startup hooks as every other knot base image. The wire protocol is Redis-compatible.

> Redis 8 is dual-licensed under the AGPL/SSPL. For the BSD-licensed open-source alternative see the parallel [`knot-valkey`](https://hub.docker.com/r/paularlott/knot-valkey) image.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-redis/tags) for the current list.

Redis is additionally tagged with a `major.minor` alias (e.g. `8.10`). Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 6379:6379 \
  -e KNOT_SERVER=https://knot.example.com \
  paularlott/knot-redis:8.10
```

By default the server binds to `127.0.0.1:6379` with protected mode enabled. Connect from the host or another space via knot port forwarding:

```bash
knot forward port 127.0.0.1:6379 <space> 6379
```

## How it works

The image layers the knot entrypoint on top of the official Redis Alpine image. On startup the entrypoint:

1. Forwards `KNOT_USER` to `redis`.
2. If `KNOT_SERVER` is set, downloads and starts the **knot agent** (as `redis`).
3. Starts `rsyslog` and forwards logs to the agent's syslog port.
4. Runs scripts in `/etc/knot-startup.d/` and `~/.knot-startup.d/`.
5. `exec`s Redis's original [`docker-entrypoint.sh`](https://github.com/docker-library/redis) with `/etc/redis/redis.conf`.

### Bundled config

`/etc/redis/redis.conf` is a tuned Redis configuration that:

- Binds to `127.0.0.1` and `::1` only, with protected mode on.
- Writes logs to **syslog** (identity `redis`) so they are captured by the knot agent.
- Uses 16 databases with default RDB/AOF persistence.

Mount your own config at `/etc/redis/redis.conf` to override.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `redis` | Runtime user (forced) |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone |

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `6379` | TCP | Redis protocol |

## Volumes

- **`/data`** — Redis's working directory (RDB snapshots / AOF). Persist this across restarts for durable data.

## License

Redis 8 is [AGPL-3.0 / SSPL](https://redis.io/docs/latest/operate/oss-and-stack/stack-license/) dual-licensed. This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
