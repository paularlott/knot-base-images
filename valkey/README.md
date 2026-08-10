# knot-valkey

A [Valkey](https://valkey.io/) image for [knot](https://getknot.dev/) spaces. Valkey is the open-source successor to Redis OSS, and this image wraps the official `valkey/valkey` image with the knot entrypoint. A Valkey instance running inside a space gets the same agent integration, `rsyslog` logging and startup hooks as every other knot base image. The wire protocol is Redis-compatible, so any Redis client can connect.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-valkey/tags) for the current list.

Valkey is additionally tagged with a `major.minor` alias (e.g. `9.1`). Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 6379:6379 \
  -e KNOT_SERVER=https://knot.example.com \
  paularlott/knot-valkey:9.1
```

By default the server binds to `127.0.0.1:6379` with protected mode enabled. Connect from the host or another space via knot port forwarding:

```bash
knot forward port 127.0.0.1:6379 <space> 6379
```

## How it works

The image layers the knot entrypoint on top of the official Valkey image. On startup the entrypoint:

1. Forwards `KNOT_USER` to `valkey`.
2. If `KNOT_SERVER` is set, downloads and starts the **knot agent** (as `valkey`).
3. Starts `rsyslog` and forwards logs to the agent's syslog port.
4. Runs scripts in `/etc/knot-startup.d/` and `~/.knot-startup.d/`.
5. `exec`s Valkey's original [`docker-entrypoint.sh`](https://github.com/valkey-io/valkey-container) with `/etc/valkey/valkey-server.conf`.

### Bundled config

`/etc/valkey/valkey-server.conf` is a tuned Valkey configuration that:

- Binds to `127.0.0.1` and `::1` only, with protected mode on.
- Writes logs to **syslog** (identity `valkey`) so they are captured by the knot agent.
- Uses 8 databases, AOF/RDB defaults, and diskless replication.

Mount your own config at `/etc/valkey/valkey-server.conf` to override.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `valkey` | Runtime user (forced) |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone |

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `6379` | TCP | Valkey / Redis protocol |

## Volumes

- **`/data`** — Valkey's working directory (RDB snapshots / AOF). Persist this across restarts for durable data.

## License

Valkey is [BSD-3-Clause](https://github.com/valkey-io/valkey/blob/8.0/COPYING). This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
