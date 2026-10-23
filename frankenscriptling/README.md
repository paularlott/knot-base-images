# knot-frankenscriptling

A **PHP** development image for [knot](https://getknot.dev/) spaces, built from the [`knot-frankenphp`](https://hub.docker.com/r/paularlott/knot-frankenphp) dev layer ([`frankenphp/`](../frankenphp/)) on [`knot-frankenscriptling-runtime`](https://hub.docker.com/r/paularlott/knot-frankenscriptling-runtime), which carries the Scriptling-enabled FrankenPHP from [`paularlott/frankenscriptling`](https://github.com/paularlott/frankenscriptling). It carries the full dev layer — ssh, git, editors, shells, Composer, Node.js, mago and mutagen — plus the same Caddy module set (DNS-01, Mercure, Vulcain, brotli, log-transform) and the Scriptling extension.

This exposes the [`Scriptling`](https://github.com/paularlott/scriptling) class to PHP, so applications can embed the Scriptling scripting/agent runtime directly:

```php
$vm = new Scriptling();
$vm->setVar('name', 'world');
echo $vm->eval('name');           // -> "world"
echo $vm->getScriptlingVersion(); // e.g. 0.20.1
```

Serve any HTML or PHP file from `~/public_html` on port 80, exactly like `knot-frankenphp`.

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
