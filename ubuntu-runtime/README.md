# knot-ubuntu-runtime

Minimal [Ubuntu](https://hub.docker.com/_/ubuntu) with the knot toolchain — the `knot-entrypoint`, runtime user handling, `rsyslog` logging, startup hooks and cron — but **no development tools**: no ssh, git, editors, shells or database clients. It is the base for [`knot-ubuntu`](https://hub.docker.com/r/paularlott/knot-ubuntu) (which adds the dev toolchain) and for lean runtime images such as [`knot-scriptling-runtime`](https://hub.docker.com/r/paularlott/knot-scriptling-runtime).

Without `KNOT_SERVER` there is no long-running foreground process, so run it with a command (or the knot agent) like any knot image.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-ubuntu-runtime/tags) for the current list. Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run --rm \
  -e KNOT_USER=alice \
  -v knot_home:/home \
  paularlott/knot-ubuntu-runtime:26.04 \
  bash -c 'echo hello from $(whoami)'
```

## Environment variables

The entrypoint mirrors `knot-ubuntu`, so it supports the common knot variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `knot` | Runtime user (uid `1000`); created if missing |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is downloaded and started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SERVICE_PASSWORD` | _(auto-generated UUID)_ | Shared service password |
| `KNOT_SSHD` | _(unset)_ | Set to `native` to start `sshd` (not installed in this image; use `knot-ubuntu`) |
| `KNOT_SSH_PORT` | `2222` | Port for the SSH daemon |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone |

## Volumes

- **`/home`** — persistent home directory.

## License

The Ubuntu base image and its packages are licensed under their respective upstream licenses. This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
