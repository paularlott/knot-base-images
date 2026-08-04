# knot-node

A [Node.js](https://nodejs.org/) development image for [knot](https://getknot.dev/) spaces, combining `knot-ubuntu` with the official Node.js runtime, `npm`, and [corepack](https://nodejs.org/api/corepack.html) (for `pnpm` / `yarn`). It is a pure runtime image — no web server — so you run your own process or app (e.g. `node server.js`, `next dev`).

It inherits the full knot entrypoint, runtime user, `rsyslog` logging and startup-hook framework from `knot-ubuntu`.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-node/tags) for the current list.

Node.js is installed from the [NodeSource](https://github.com/nodesource/distributions) deb repository; the `<version>` tag is the Node major (e.g. `24`), tracking the latest patch of that line. Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_USER=alice \
  -v knot_home:/home \
  paularlott/knot-node:24
```

Then, in the space:

```bash
npm init -y
npm install express
node -e 'require("express"); console.log("express loaded")'
```

Or with `pnpm` (via corepack):

```bash
corepack prepare pnpm@latest --activate
pnpm init
```

## How it works

Builds on `knot-ubuntu:26.04`. The latest Node.js `<major>.x` release is installed from the NodeSource deb repository, and [corepack](https://nodejs.org/api/corepack.html) is enabled so `pnpm` and `yarn` are available on demand. `24` is the current LTS; `26` is the current release line.

## Environment variables

Built on `knot-ubuntu`, so it supports the common knot variables (`KNOT_USER`, `KNOT_SERVER`, `KNOT_SPACEID`, `KNOT_SYSLOG_PORT`, `TZ`, …).

Node-specific:

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_MAJOR` | _(build-time)_ | The Node.js major version (e.g. `24`) |

## Volumes

- **`/home`** — persistent home directory; `node_modules` and projects live here.

## License

Node.js is [MIT](https://github.com/nodejs/node/blob/HEAD/LICENSE). This image's packaging — the Dockerfile and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
