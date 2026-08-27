# knot-scriptling-runtime

A lean [Scriptling](https://github.com/paularlott/scriptling) runtime image for [knot](https://getknot.dev/) spaces: Alpine with the Scriptling interpreter and the knot entrypoint framework, but **no dev tools** — no ssh, git, editors, extra shells, db clients or mutagen. Use [`knot-scriptling`](https://hub.docker.com/r/paularlott/knot-scriptling) when you need the full development toolchain.

Scriptling is a minimal, sandboxed, Python-like scripting language for Go — designed for LLM agents to execute code and interact with REST APIs. The image's default command runs the Scriptling HTTP server on `:8080`; pass any other `scriptling` command to use the interpreter, REPL or one-shot scripts instead.

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

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-scriptling-runtime/tags) for the current list.

- `<version>` (e.g. `0.20.1`), plus a rolling `major.minor` tag (e.g. `0.20`) and `latest`.

Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 8080:8080 \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_USER=alice \
  -v knot_home:/home \
  paularlott/knot-scriptling-runtime:0.20.1
```

With no command the container runs `scriptling --server 0.0.0.0:8080`, so it stays up serving the Scriptling HTTP API. Any command replaces it:

```bash
docker run --rm -v knot_home:/home paularlott/knot-scriptling-runtime:0.20.1 scriptling hello.sl
```

To let LLM clients execute Scriptling code over MCP, enable the exec tool — and protect it with a bearer token, since it runs the code it is sent:

```bash
docker run -d -p 8080:8080 paularlott/knot-scriptling-runtime:0.20.1 \
  scriptling --server 0.0.0.0:8080 --mcp-exec-script --bearer-token secret
```

## Environment variables

Built on the knot entrypoint, so it supports the common knot variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `knot` | Runtime user (uid `1000`); created if missing |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is downloaded and started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SERVICE_PASSWORD` | _(auto-generated UUID)_ | Shared service password |
| `KNOT_SSHD` | _(unset)_ | Set to `native` to start `sshd` (not installed in this image; use `knot-scriptling`) |
| `KNOT_SSH_PORT` | `2222` | Port for the SSH daemon |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone |

Scriptling-specific:

| Variable | Default | Description |
|----------|---------|-------------|
| `SCRIPTLING_VERSION` | _(build-time)_ | The Scriptling release the image was built with (e.g. `v0.20.1`) |

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8080` | TCP | Scriptling HTTP server (default command) |

## Volumes

- **`/home`** — persistent home directory; scripts and projects live here.

## License

Scriptling is [Apache License 2.0](https://github.com/paularlott/scriptling/blob/main/LICENSE.txt). This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
