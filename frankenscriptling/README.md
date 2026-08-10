# knot-frankenscriptling

A **PHP** development image for [knot](https://getknot.dev/) spaces that bundles [Scriptling](https://github.com/paularlott/scriptling) as a native FrankenPHP PHP extension. It is identical to [`knot-frankenphp`](https://hub.docker.com/r/paularlott/knot-frankenphp) — same knot toolchain, runtime user, `rsyslog`, startup hooks, Composer, Node.js and Caddy modules (DNS-01, Mercure, Vulcain, brotli, log-transform) — but the FrankenPHP/Caddy binary is rebuilt with `xcaddy` to additionally include the Scriptling extension.

This exposes the [`Scriptling`](https://github.com/paularlott/scriptling) class to PHP, so applications can embed the Scriptling scripting/agent runtime directly:

```php
$vm = new Scriptling();
$vm->setVar('name', 'world');
echo $vm->eval('name');           // -> "world"
echo $vm->getScriptlingVersion(); // e.g. 0.20.1
```

Serve any HTML or PHP file from `~/public_html` on port 80, exactly like `knot-frankenphp`.

## How it builds

1. **Builder** — starts from the official FrankenPHP builder, initialises a Go module that imports `github.com/paularlott/scriptling`, runs `frankenphp extension-init` to generate the PHP extension stubs from [`scriptling_ext.go`](https://github.com/paularlott/knot-base-images/blob/main/frankenscriptling/scriptling_ext.go), then compiles FrankenPHP with `xcaddy` using the same module set as `knot-frankenphp` plus the Scriptling module.
2. **Runtime** — `FROM` the published `knot-frankenphp` image and copies in the Scriptling-enabled FrankenPHP binary. Everything else (entrypoint, Caddyfile, startup hooks, CLI tooling) is inherited unchanged from `knot-frankenphp`.

Scriptling tracks an upstream release tag; override with `SCRIPTLING_VERSION` (default `v0.20.1`).

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-frankenscriptling/tags) for the current list. Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 8080:80 \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_USER=alice \
  -v knot_home:/home \
  paularlott/knot-frankenscriptling:8.5
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
| `KNOT_SSHD` | _(unset)_ | Set to `native` to start `sshd` |
| `KNOT_SSH_PORT` | `2222` | Port for the SSH daemon |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone (also sets `date.timezone`) |

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `80` | TCP | HTTP (FrankenPHP) |
| `443` | TCP/UDP | HTTPS / HTTP/3 (when enabled) |
| `2019` | TCP | Caddy admin API |

## Volumes

- **`/home`** — persistent home directory; serve content from `~/public_html`.

## License

FrankenPHP is [MIT](https://github.com/dunglas/frankenphp/blob/main/LICENSE). Scriptling retains its own licence — see [paularlott/scriptling](https://github.com/paularlott/scriptling). This image's packaging is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
