# knot-desktop

An **Ubuntu desktop** image for [knot](https://getknot.dev/) spaces that serves a full [XFCE](https://www.xfce.org/) environment in the browser via [KasmVNC](https://github.com/kasmtech/KasmVNC). It builds on `knot-ubuntu`, inheriting its runtime user, logging and startup framework, and adds a preconfigured desktop with Chromium and the Nordic theme.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-desktop/tags) for the current list.

Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  --privileged \
  -p 5680:5680 \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_USER=alice \
  -e KNOT_VNC_HTTP_PORT=5680 \
  -e KNOT_SERVICE_PASSWORD=changeme \
  -v knot_home:/home \
  paularlott/knot-desktop:26.04
```

The desktop is then available on the configured VNC HTTP port (`KNOT_VNC_HTTP_PORT`, default `5680`). The VNC password is the value of `KNOT_SERVICE_PASSWORD`.

> KasmVNC requires the container to run **privileged** (or with the appropriate device / capability permissions) for input and graphics support.

## How it works

On top of the `knot-ubuntu` entrypoint, a startup hook (`/etc/knot-startup.d/01-start-desktop`) is added that:

1. Starts the D-Bus system bus.
2. Seeds the user's `.themes` and `.config/xfce4` from bundled defaults (Nordic theme + wallpaper) on first run.
3. Sets the KasmVNC password to `KNOT_SERVICE_PASSWORD`.
4. Launches `vncserver :1` on `0.0.0.0` exposing the XFCE session over `KNOT_VNC_HTTP_PORT`.

The default browser is **Chromium**, installed as a Flatpak and wrapped by `/usr/local/bin/chromium`.

## Environment variables

Built on `knot-ubuntu`, so it supports the common knot variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `knot` | Runtime user (uid `1000`); created if missing |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is downloaded and started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SERVICE_PASSWORD` | _(auto-generated UUID)_ | Shared service password (also the VNC password) |
| `KNOT_SSHD` | _(unset)_ | Set to `native` to start `sshd` |
| `KNOT_SSH_PORT` | `2222` | Port for the SSH daemon |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone |

Desktop additions:

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_VNC_HTTP_PORT` | `5680` | HTTP port the KasmVNC web client listens on |
| `WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS` | `1` | Allows Epiphany to run inside the container |

## Volumes

- **`/home`** — persistent home directory. Desktop configuration and themes are seeded into the user's home on first start.

## Included software

- **XFCE 4** desktop with `xfce4-terminal`, `xterm` and goodies.
- **KasmVNC** for browser-based access.
- **Chromium** (Flatpak) as the default browser.
- **Epiphany** (GNOME Web).
- The full `knot-ubuntu` CLI toolset (git, vim, fish, tmux, make, jq, ripgrep, fzf, cron, rsyslog, …).

## License

The Ubuntu base image and its packages (including XFCE, KasmVNC and Chromium) are licensed under their respective upstream licenses. This image's packaging — the Dockerfile and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
