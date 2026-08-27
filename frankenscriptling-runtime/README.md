# knot-frankenscriptling-runtime

[FrankenPHP](https://frankenphp.dev/) (Caddy + PHP in a single process) with the [Scriptling](https://github.com/paularlott/scriptling) PHP extension and the knot toolchain but **no development tools** — no ssh, git, editors, Node.js or Composer. It is [`knot-frankenphp-runtime`](https://hub.docker.com/r/paularlott/knot-frankenphp-runtime) with the FrankenPHP/Caddy binary rebuilt to additionally include the Scriptling extension, and it is the base for [`knot-frankenscriptling`](https://hub.docker.com/r/paularlott/knot-frankenscriptling) (which adds the dev layer).

This exposes the [`Scriptling`](https://github.com/paularlott/scriptling) class to PHP, so applications can embed the Scriptling scripting/agent runtime directly:

```php
$vm = new Scriptling();
$vm->setVar('name', 'world');
echo $vm->eval('name');           // -> "world"
echo $vm->getScriptlingVersion(); // e.g. 0.21.3
```

Serve any HTML or PHP file from `~/public_html` on port 80, exactly like `knot-frankenphp-runtime`. Without `KNOT_SERVER` there is no long-running foreground process, so run it with a command (or the knot agent) like any knot image.

## How it works

A startup hook (`/etc/knot-startup.d/01-startup-frankenphp`):

1. Installs `/etc/cron.d/container-crons` and starts `cron`.
2. Creates `~/public_html` if missing.
3. Starts **FrankenPHP** with the bundled `/etc/frankenphp/Caddyfile`, which serves `~/public_html` via `php_server`, logs to syslog, and runs the admin API on `127.0.0.1:2019`.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-frankenscriptling-runtime/tags) for the current list.

Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 8080:80 \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_USER=alice \
  -v knot_home:/home \
  paularlott/knot-frankenscriptling-runtime:8.5
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
| `KNOT_SSHD` | _(unset)_ | Set to `native` to start `sshd` (not installed in this image; use `knot-frankenscriptling`) |
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
