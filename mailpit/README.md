# knot-mailpit

A [Mailpit](https://github.com/axllent/mailpit) image for [knot](https://getknot.dev/) spaces. It wraps the official `axllent/mailpit` Alpine image with the knot entrypoint, so a Mailpit instance running inside a space gets the same agent integration, `rsyslog` logging and startup hooks as every other knot base image. It is otherwise a standard Mailpit container.

Mailpit is an SMTP mail catcher for developers. It runs an SMTP server and a web UI for inspecting captured mail.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-mailpit/tags) for the current list.

Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 8025:8025 \
  -p 1025:1025 \
  -e KNOT_SERVER=https://knot.example.com \
  -v mailpit_data:/data \
  paularlott/knot-mailpit:1.30
```

Point your application at the SMTP server (from the host or another space) via knot port forwarding:

```bash
knot forward port 127.0.0.1:1025 <space> 1025
```

Open the web UI the same way — forward port `8025` and browse to it.

## How it works

The image layers the knot entrypoint on top of the official Mailpit image. On startup the entrypoint:

1. Forces `KNOT_USER` to `mailpit` (a service user created at build time — the upstream image runs as `root`).
2. If `KNOT_SERVER` is set, downloads and starts the **knot agent** (as `mailpit`).
3. Starts `rsyslog` and forwards logs to the agent's syslog port.
4. Runs scripts in `/etc/knot-startup.d/` and `~/.knot-startup.d/`.
5. `exec`s `/mailpit` as the `mailpit` user, piping its output to syslog so the agent captures it.

### Mailpit customizations

- **Service user** — the upstream image ships no service user, so a `mailpit` user (home `/home/mailpit`) is created and Mailpit is run as it via `gosu`.
- **Persistent database** — the default command sets `--database /data/mailpit.db` so captured mail survives restarts when `/data` is persisted.
- **Syslog logging** — Mailpit logs to stdout; the entrypoint pipes that to `rsyslog` (tag `mailpit`) because Mailpit has no native syslog support and the knot agent collects logs over syslog.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `mailpit` | Runtime user (forced) |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone |

Plus any Mailpit command-line flags passed via `CMD` (e.g. `--smtp`, `--listen`, `--smtp-auth-accept-any`). See `mailpit --help`.

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `1025` | TCP | SMTP server |
| `8025` | TCP | Web UI & API |
| `1110` | TCP | POP3 server (optional — requires `--pop3-auth-file`) |

## Volumes

- **`/data`** — Mailpit's database (`mailpit.db`); persist this across restarts to keep captured mail.

## License

Mailpit is [MIT](https://github.com/axllent/mailpit/blob/dev/LICENSE). This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
