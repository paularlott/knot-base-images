# knot-go

A [Go](https://go.dev/) development image for [knot](https://getknot.dev/) spaces, combining `knot-ubuntu` with the official Go toolchain. It bundles no web server, so you run your own process or compiled binary.

It inherits the full knot entrypoint, runtime user, `rsyslog` logging and startup-hook framework from `knot-ubuntu`.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-go/tags) for the current list.

Go is installed from the official [go.dev](https://go.dev/dl/) tarball; the `<version>` tag tracks the latest patch of that Go release line (e.g. `1.26` → `1.26.x`). Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_USER=alice \
  -v knot_home:/home \
  paularlott/knot-go:1.26
```

Then, in the space:

```bash
go mod init hello
cat > main.go <<'EOF'
package main
import "fmt"
func main() { fmt.Println("hello, knot") }
EOF
go run main.go
```

## How it works

Builds on `knot-ubuntu:26.04`. The Go toolchain (the latest `<version>.x` stable release) is unpacked into `/usr/local/go` (`GOROOT`), with `GOPATH=/home/.go` so `go install`ed binaries and the module cache persist with the `/home` volume. `gcc`/`build-essential` are included for [CGO](https://pkg.go.dev/cmd/cgo).

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

Go-specific:

| Variable | Default | Description |
|----------|---------|-------------|
| `GOROOT` | `/usr/local/go` | Go installation root |
| `GOPATH` | `/home/.go` | Workspace / module cache (persisted via `/home`) |

## Volumes

- **`/home`** — persistent home directory; `GOPATH` (`/home/.go`) lives here.

## License

Go is [BSD-3-Clause](https://go.dev/LICENSE). This image's packaging — the Dockerfile and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
