# knot-victoria-logs

A [VictoriaLogs](https://docs.victoriametrics.com/victorialogs/) image for [knot](https://getknot.dev/) spaces. The upstream `victoriametrics/victoria-logs` image is distroless, so this image lifts the statically-linked `victoria-logs-prod` binary out and rebases it onto Alpine with the knot entrypoint. [vmauth](https://docs.victoriametrics.com/victoriametrics/vmauth/) is bundled to provide HTTP basic auth (username/password) in front of VictoriaLogs. A VictoriaLogs instance running inside a space gets the same agent integration, `rsyslog` logging and startup hooks as every other knot base image.

The image supports running as a **log sink** on knot Pro: setting `KNOT_LOG_SINK_PORT=9428` (off by default) makes the space receive a mirror of the logs of the owner's other spaces in the zone, written straight into VictoriaLogs. The wire format defaults to `vl` (VictoriaLogs jsonline) via `KNOT_LOG_SINK_FORMAT` — no need to set it for this image, but it can be changed (`loki`, `gelf`, `json`) if you front the port with something else. Requires the *Use Log Sinks* permission. See the knot docs on [Log Sinks](https://getknot.dev/docs/spaces/log-sinks).

VictoriaLogs accepts logs over HTTP (Elasticsearch, Loki, JSON and syslog ingest) and queries them with [LogsQL](https://docs.victoriametrics.com/victorialogs/logsql/).

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-victoria-logs/tags) for the current list.

Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 9428:9428 \
  -e VICTORIA_LOGS_USERNAME=alice \
  -e VICTORIA_LOGS_PASSWORD=changeme \
  -e KNOT_SERVER=https://knot.example.com \
  -v vlogs_data:/data \
  paularlott/knot-victoria-logs:1.52.0
```

With `VICTORIA_LOGS_USERNAME` / `VICTORIA_LOGS_PASSWORD` set, every request to `:9428` (ingest, query and web UI) is gated by HTTP basic auth via [vmauth](https://docs.victoriametrics.com/victoriametrics/vmauth/). Leave them unset to run without auth (development mode).

To run the space as a knot Pro **log sink** (receiving the logs of the owner's other spaces), enable it explicitly — it is off by default. `KNOT_LOG_SINK_FORMAT` is optional (`vl` is the default and correct for this image):

```bash
docker run -d \
  -p 9428:9428 \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_LOG_SINK_PORT=9428 \
  -e KNOT_LOG_SINK_FORMAT=vl \
  -v vlogs_data:/data \
  paularlott/knot-victoria-logs:1.52.0
```

Ingest a log entry (JSON line — note `_stream` must be a JSON object):

```bash
curl -X POST http://localhost:9428/insert/jsonline \
  -u alice:changeme \
  -H 'Content-Type: application/stream+json' \
  -d '{"_msg":"hello","_stream":{"app":"demo"},"_time":"2026-01-01T00:00:00Z","level":"info"}'
```

Query it back via the API or from the host / another space via knot port forwarding:

```bash
knot forward port 127.0.0.1:9428 <space> 9428
curl -u alice:changeme 'http://localhost:9428/select/logsql/query?query=*'
```

The web UI at `http://localhost:9428/` will prompt for the same username and password.

### Direct (no-auth) access for the agent

Inside the space, VictoriaLogs also listens on `127.0.0.1:8428` **without auth** (vmauth only fronts the exposed `:9428`). The knot agent and other in-space processes can ingest or query direct, with no password:

```bash
# from within the space — no auth needed
curl -X POST http://127.0.0.1:8428/insert/jsonline \
  -H 'Content-Type: application/stream+json' \
  -d '{"_msg":"agent log","_stream":{"app":"demo"}}'
```

From the host you can tunnel straight to that internal port too:

```bash
knot forward port 127.0.0.1:8428 <space> 8428
curl 'http://localhost:8428/select/logsql/query?query=*'
```

## How it works

The upstream image is `FROM scratch` (no shell, no package manager), so the build copies the static `victoria-logs-prod` binary (and the `vmauth-prod` auth proxy) into an Alpine base that carries the knot toolchain. On startup the entrypoint:

1. Forces `KNOT_USER` to `victoria-logs` (a service user created at build time).
2. If `KNOT_SERVER` is set, downloads and starts the **knot agent** (as `victoria-logs`).
3. Starts `rsyslog` and forwards logs to the agent's syslog port.
4. Runs scripts in `/etc/knot-startup.d/` and `~/.knot-startup.d/`.
5. If `VICTORIA_LOGS_USERNAME` / `VICTORIA_LOGS_PASSWORD` are set, generates a vmauth config and starts **vmauth** on `:9428` (basic auth) proxying to VictoriaLogs on `127.0.0.1:8428`; otherwise VictoriaLogs listens on `:9428` directly.
6. `exec`s `victoria-logs` as the `victoria-logs` user, piping its output to syslog so the agent captures it.

### VictoriaLogs customizations

- **Rebased onto Alpine** — the upstream distroless image has no shell, so it is rebased onto Alpine to carry `rsyslog`, `gosu`, `sudo` and the service user.
- **Built-in auth** — [vmauth](https://docs.victoriametrics.com/victoriametrics/vmauth/) is bundled and fronts the exposed `:9428`. When `VICTORIA_LOGS_USERNAME` / `VICTORIA_LOGS_PASSWORD` are set, all traffic on `:9428` (ingest, query, web UI) requires HTTP basic auth; the entrypoint writes the vmauth config from those env vars on each start. The internal `127.0.0.1:8428` stays open for the agent and in-space services.
- **Service user** — a `victoria-logs` user (home `/home/victoria-logs`) is created and the server is run as it via `gosu`.
- **Persistent storage** — the default command sets `-storageDataPath /data` so log data survives restarts when `/data` is persisted.
- **Retention** — defaults to 30 days via the `VICTORIA_LOGS_RETENTION_PERIOD` env var (passed as `-retentionPeriod`). Override it (e.g. `7d`, `365d`) without editing the command.
- **Syslog logging** — VictoriaLogs logs to stderr; the entrypoint pipes that to `rsyslog` (tag `victoria-logs`) because it has no native syslog support and the knot agent collects logs over syslog. vmauth output is captured the same way (tag `vmauth`).

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `victoria-logs` | Runtime user (forced) |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `KNOT_LOG_SINK_PORT` | _(unset — off)_ | Advertise the space as a **log sink** (knot Pro): the knot server mirrors the logs of the space owner's other spaces to this port. Off by default — set to `9428` to enable. |
| `KNOT_LOG_SINK_FORMAT` | `vl` | Format the agent writes mirrored logs in: `vl` (VictoriaLogs jsonline), `loki`, `gelf` or `json` |
| `VICTORIA_LOGS_USERNAME` | _(unset)_ | Basic-auth username for vmauth; if set with the password, auth is enabled |
| `VICTORIA_LOGS_PASSWORD` | _(unset)_ | Basic-auth password for vmauth |
| `VICTORIA_LOGS_RETENTION_PERIOD` | `30d` | How long to keep logs (`-retentionPeriod`). E.g. `7d`, `365d`. |
| `TZ` | `Etc/UTC` | Timezone |

In a knot space these are typically populated from the user's profile:

```yaml
environment:
  - VICTORIA_LOGS_USERNAME=${{.user.username}}
  - VICTORIA_LOGS_PASSWORD=${{.user.service_password}}
```

Plus any VictoriaLogs command-line flags passed via `CMD` (e.g. `-retentionPeriod`, `-httpListenAddr`). See `victoria-logs -help`.

## Ports

| Port | Bound to | Auth | Purpose |
|------|----------|------|---------|
| `9428` | `0.0.0.0` (exposed) | basic auth (when `VICTORIA_LOGS_USERNAME`/`VICTORIA_LOGS_PASSWORD` set) | HTTP API, ingestion, query and web UI — use for remote / port-forwarded access |
| `8428` | `127.0.0.1` (loopback only) | none | VictoriaLogs direct — for the knot agent and in-space services to ingest/query without a password |

If auth credentials are **not** set, vmauth is skipped and VictoriaLogs listens on `:9428` directly (no auth on either port).

## Volumes

- **`/data`** — VictoriaLogs storage directory; persist this across restarts to keep log data.

## License

VictoriaLogs is [Apache License 2.0](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/LICENSE). This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
