# knot-ubuntu

Base **Ubuntu** image used by [knot](https://getknot.dev/), a tool for managing cloud and local development environments. It is the foundation that the `knot-desktop`, `knot-php` and other Ubuntu-based knot images build upon, but it is also useful on its own as a general-purpose, fully-tooled development container.

The image adds the knot entrypoint and startup framework, a runtime user, `rsyslog` logging, `gosu`, and a broad set of CLI utilities to every container.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-ubuntu/tags) for the current list.

Each release is also tagged `<version>-<BUILD_DATE>` (e.g. `24.04-20260101`).

## Usage

### As a knot space

When `KNOT_SERVER` is set the entrypoint downloads the knot agent and connects the container to your knot cluster:

```bash
docker run -d \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_SPACEID=... \
  -e KNOT_USER=alice \
  -v knot_home:/home \
  paularlott/knot-ubuntu:26.04
```

### Standalone

With no `KNOT_SERVER`, the image still sets up the runtime user, home directory, `rsyslog` and startup hooks, then waits (or runs the command you pass):

```bash
# Interactive shell as the runtime user
docker run --rm -it -v knot_home:/home paularlott/knot-ubuntu:26.04 bash

# Run a one-off command
docker run --rm paularlott/knot-ubuntu:26.04 whoami
```

## How it works

The `ENTRYPOINT` is `/usr/local/bin/knot-entrypoint`, which:

1. Creates the `KNOT_USER` (uid `1000`) if missing, renames the home directory if the user changed, and fixes ownership. The user is granted passwordless `sudo`.
2. Optionally starts `sshd` on `KNOT_SSH_PORT` when `KNOT_SSHD=native`.
3. If `KNOT_SERVER` is set, downloads and starts the **knot agent** (granted `CAP_NET_BIND_SERVICE`).
4. Starts `rsyslog` and forwards all logs to the agent's syslog port (`KNOT_SYSLOG_PORT`).
5. Runs every script in `/etc/knot-startup.d/` alphabetically, then `~/.knot-startup.d/`.
6. Waits on the agent (or `exec`s the supplied command as `KNOT_USER`).

### Startup hooks

Drop executable scripts into:

- `/etc/knot-startup.d/` — system hooks, run as root.
- `~/.knot-startup.d/` — per-user hooks, run as `KNOT_USER` via `gosu`.

See the [knot startup-scripts docs](https://getknot.dev/docs/spaces/startup-scripts/) for details.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `knot` | Runtime user (uid `1000`); created if missing |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is downloaded and started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SERVICE_PASSWORD` | _(auto-generated UUID)_ | Shared service password |
| `KNOT_WILDCARD_DOMAIN` | _(unset)_ | Wildcard domain for the space |
| `KNOT_SSHD` | _(unset)_ | Set to `native` to start `sshd` |
| `KNOT_SSH_PORT` | `2222` | Port for the SSH daemon |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `KNOT_LOGLEVEL` | _(unset)_ | Agent log level |
| `TZ` | `Etc/UTC` | Timezone |
| `LANG` / `LC_ALL` | `en_US.UTF-8` | Locale |

## Volumes

- **`/home`** — persistent home directory for `KNOT_USER`. Mount this to preserve work across restarts.

## License

The Ubuntu base image and its packages are licensed under their respective upstream licenses. This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
