# knot-scriptling

A [Scriptling](https://github.com/paularlott/scriptling) development image for [knot](https://getknot.dev/) spaces, combining `knot-ubuntu` with the Scriptling interpreter and CLI. Scriptling is a minimal, sandboxed, Python-like scripting language for Go — designed for LLM agents to execute code and interact with REST APIs. It bundles no web server, though the CLI can act as one via `scriptling --server`.

It inherits the full knot entrypoint, runtime user, `rsyslog` logging and startup-hook framework from `knot-ubuntu`.

An **Alpine variant** (`<version>-alpine` tags) provides the same toolchain on an Alpine base for a smaller footprint — see [below](#alpine-variant).

Need just the interpreter without the dev toolchain? Use [`knot-scriptling-runtime`](https://hub.docker.com/r/paularlott/knot-scriptling-runtime) — Alpine with the knot entrypoint and the Scriptling binary, nothing else.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-scriptling/tags) for the current list.

- `<version>` — Ubuntu 26.04 base (e.g. `0.20.2`), plus a rolling `major.minor` tag (e.g. `0.20`).
- `<version>-alpine` — Alpine base (e.g. `0.20.2-alpine`), plus a rolling `<major.minor>-alpine` tag (e.g. `0.20-alpine`).

Each release is also tagged `<version>-<BUILD_DATE>` / `<version>-alpine-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_USER=alice \
  -v knot_home:/home \
  paularlott/knot-scriptling:0.20.1
```

Then, in the space:

```bash
echo 'print("hello from scriptling")' > hello.sl
scriptling hello.sl
```

Interactive REPL, inline code, and the built-in HTTP / JSON-RPC / MCP server modes:

```bash
scriptling -i
scriptling -c 'print("hello")'
scriptling --server 0.0.0.0:8080 --mcp-exec-script
```

## How it works

Builds on `knot-ubuntu:26.04`. Scriptling is installed as the self-contained static binary `/usr/local/bin/scriptling` — no interpreter dependencies are required.

## Alpine variant

The `<version>-alpine` tags are the [`knot-alpine`](../alpine/README.md) sibling — the same tooling as `knot-ubuntu` mapped to Alpine packages (git, vim, fish, tmux, ripgrep, bat, fzf, zoxide, jq, make, ssh, mariadb-client, postgresql-client, valkey-cli, rsyslog, gosu, mutagen, …) — plus the static Scriptling binary, which works on musl. See the [knot-alpine README](../alpine/README.md) for the Ubuntu↔Alpine package mapping and entrypoint differences.

## Environment variables

Built on `knot-ubuntu`, so it supports the common knot variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `knot` | Runtime user (uid `1000`); created if missing |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is downloaded and started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SERVICE_PASSWORD` | _(auto-generated UUID)_ | Shared service password |
| `KNOT_SSHD` | _(unset)_ | Set to `native` to start `sshd` |
| `KNOT_SSH_PORT` | `2222` | Port for the SSH daemon |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone |

Scriptling-specific:

| Variable | Default | Description |
|----------|---------|-------------|
| `SCRIPTLING_VERSION` | _(build-time)_ | The Scriptling release the image was built with (e.g. `v0.20.1`) |

## Volumes

- **`/home`** — persistent home directory; scripts and projects live here.

## License

Scriptling is [Apache License 2.0](https://github.com/paularlott/scriptling/blob/main/LICENSE.txt). This image's packaging — the Dockerfile and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
