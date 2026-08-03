# knot-victoria-logs

A [VictoriaLogs](https://docs.victoriametrics.com/victorialogs/) image for [knot](https://getknot.dev/) spaces. The upstream `victoriametrics/victoria-logs` image is distroless, so this image lifts the statically-linked `victoria-logs-prod` binary out and rebases it onto Alpine with the knot entrypoint. A VictoriaLogs instance running inside a space gets the same agent integration, `rsyslog` logging and startup hooks as every other knot base image.

VictoriaLogs is a cost-efficient, high-performance log database from the VictoriaMetrics team. It accepts logs over HTTP (Elasticsearch, Loki, JSON and syslog ingest) and queries them with [LogsQL](https://docs.victoriametrics.com/victorialogs/logsql/).

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-victoria-logs/tags) for the current list.

Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 9428:9428 \
  -e KNOT_SERVER=https://knot.example.com \
  -v vlogs_data:/data \
  paularlott/knot-victoria-logs:1.52.0
```

Ingest a log entry (JSON line — note `_stream` must be a JSON object):

```bash
curl -X POST http://localhost:9428/insert/jsonline \
  -H 'Content-Type: application/stream+json' \
  -d '{"_msg":"hello","_stream":{"app":"demo"},"_time":"2026-01-01T00:00:00Z","level":"info"}'
```

Query it back via the API or from the host / another space via knot port forwarding:

```bash
knot forward port 127.0.0.1:9428 <space> 9428
curl 'http://localhost:9428/select/logsql/query?query=*'
```

## How it works

The upstream image is `FROM scratch` (no shell, no package manager), so the build copies the static `victoria-logs-prod` binary into an Alpine base that carries the knot toolchain. On startup the entrypoint:

1. Forces `KNOT_USER` to `victoria-logs` (a service user created at build time).
2. If `KNOT_SERVER` is set, downloads and starts the **knot agent** (as `victoria-logs`).
3. Starts `rsyslog` and forwards logs to the agent's syslog port.
4. Runs scripts in `/etc/knot-startup.d/` and `~/.knot-startup.d/`.
5. `exec`s `victoria-logs` as the `victoria-logs` user, piping its output to syslog so the agent captures it.

### VictoriaLogs customizations

- **Rebased onto Alpine** — the upstream distroless image has no shell, so it is rebased onto Alpine to carry `rsyslog`, `gosu`, `sudo` and the service user.
- **Service user** — a `victoria-logs` user (home `/home/victoria-logs`) is created and the server is run as it via `gosu`.
- **Persistent storage** — the default command sets `-storageDataPath /data` so log data survives restarts when `/data` is persisted.
- **Retention** — defaults to 30 days via the `VICTORIA_LOGS_RETENTION_PERIOD` env var (passed as `-retentionPeriod`). Override it (e.g. `7d`, `365d`) without editing the command.
- **Syslog logging** — VictoriaLogs logs to stderr; the entrypoint pipes that to `rsyslog` (tag `victoria-logs`) because it has no native syslog support and the knot agent collects logs over syslog.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `victoria-logs` | Runtime user (forced) |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `VICTORIA_LOGS_RETENTION_PERIOD` | `30d` | How long to keep logs (`-retentionPeriod`). E.g. `7d`, `365d`. |
| `TZ` | `Etc/UTC` | Timezone |

Plus any VictoriaLogs command-line flags passed via `CMD` (e.g. `-retentionPeriod`, `-httpListenAddr`). See `victoria-logs -help`.

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9428` | TCP | HTTP API, ingestion and web UI |

## Volumes

- **`/data`** — VictoriaLogs storage directory; persist this across restarts to keep log data.

## License

VictoriaLogs is [Apache License 2.0](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/LICENSE). This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
