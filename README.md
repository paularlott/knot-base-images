# knot-base-images

<div align="center">

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

</div>

The base container images used by [**knot**](https://getknot.dev/) — a tool for managing cloud and local development environments. Each image ships with a common `knot-entrypoint` that wires up a runtime user, `rsyslog` logging, startup hooks, and (when paired with a knot server) the knot agent.

These images are designed first and foremost for **knot spaces**, but they are ordinary OCI images and work standalone with `docker` / `podman` / Nomad.

## Available images

| Image | Description | Directory |
|-------|-------------|-----------|
| [`knot-ubuntu`](ubuntu/README.md) | Base Ubuntu image with the knot toolchain and startup-hook framework. | [`ubuntu/`](ubuntu/) |
| [`knot-alpine`](alpine/README.md) | Base Alpine image with the knot toolchain and startup-hook framework. | [`alpine/`](alpine/) |
| [`knot-desktop`](desktop/README.md) | Ubuntu + an XFCE desktop served over the web via KasmVNC. Builds on `knot-ubuntu`. | [`desktop/`](desktop/) |
| [`knot-caddy`](caddy/README.md) | Caddy web server built with `xcaddy`, including DNS-01 and TLS storage modules. | [`caddy/`](caddy/) |
| [`knot-php`](php/README.md) | Ubuntu + Caddy + PHP-FPM, Composer and Node.js — serves `~/public_html`. | [`php/`](php/) |
| [`knot-frankenphp-runtime`](frankenphp-runtime/README.md) | FrankenPHP (Caddy + PHP in one process) with the knot toolchain but no dev tools — base for appliances. | [`frankenphp-runtime/`](frankenphp-runtime/) |
| [`knot-frankenphp`](frankenphp/README.md) | `knot-frankenphp-runtime` + dev tools: ssh, git, editors, shells, Composer, Node.js, mago and mutagen. | [`frankenphp/`](frankenphp/) |
| [`knot-frankenscriptling-runtime`](frankenscriptling-runtime/README.md) | `knot-frankenphp-runtime` + the Scriptling PHP extension — no dev tools. | [`frankenscriptling-runtime/`](frankenscriptling-runtime/) |
| [`knot-frankenscriptling`](frankenscriptling/README.md) | `knot-frankenphp` + the Scriptling PHP extension. | [`frankenscriptling/`](frankenscriptling/) |
| [`knot-go`](go/README.md) | Ubuntu + the Go toolchain — pure runtime image. | [`go/`](go/) |
| [`knot-python`](python/README.md) | Ubuntu + Python and `uv` — pure runtime image. | [`python/`](python/) |
| [`knot-node`](node/README.md) | Ubuntu + Node.js LTS and corepack (`pnpm` / `yarn`) — pure runtime image. | [`node/`](node/) |
| [`knot-scriptling`](scriptling/README.md) | Ubuntu or Alpine + the Scriptling interpreter and CLI — pure runtime image. | [`scriptling/`](scriptling/) |
| [`knot-scriptling-runtime`](scriptling-runtime/README.md) | Alpine + the Scriptling interpreter and knot toolchain — no dev tools. | [`scriptling-runtime/`](scriptling-runtime/) |
| [`knot-mariadb`](mariadb/README.md) | MariaDB with the knot entrypoint, agent integration and syslog logging. | [`mariadb/`](mariadb/) |
| [`knot-mysql`](mysql/README.md) | MySQL with the knot entrypoint, agent integration and syslog logging. | [`mysql/`](mysql/) |
| [`knot-postgres`](postgres/README.md) | PostgreSQL with the knot entrypoint, agent integration and syslog logging. | [`postgres/`](postgres/) |
| [`knot-valkey`](valkey/README.md) | Valkey (the Redis fork) with the knot entrypoint, agent integration and syslog logging. | [`valkey/`](valkey/) |
| [`knot-redis`](redis/README.md) | Redis with the knot entrypoint, agent integration and syslog logging. | [`redis/`](redis/) |
| [`knot-mailpit`](mailpit/README.md) | Mailpit SMTP mail catcher with the knot entrypoint, agent integration and syslog logging. | [`mailpit/`](mailpit/) |
| [`knot-adminer`](adminer/README.md) | Adminer on knot-frankenphp-runtime — manages MySQL/MariaDB, PostgreSQL and Redis. | [`adminer/`](adminer/) |
| [`knot-victoria-logs`](victoria-logs/README.md) | VictoriaLogs log database (rebased onto Alpine) with the knot entrypoint, agent integration and syslog logging. | [`victoria-logs/`](victoria-logs/) |

## Image relationships

```
knot-ubuntu ──┬── knot-desktop
              ├── knot-php ── (uses knot-caddy)
              ├── knot-go
              ├── knot-python
              ├── knot-node
              └── knot-scriptling
knot-alpine ──── knot-scriptling (<version>-alpine tags)
knot-scriptling-runtime (standalone, Alpine base + knot toolchain + Scriptling, no dev tools)
knot-caddy
knot-frankenphp-runtime (standalone, official FrankenPHP base + knot toolchain, no dev tools)
knot-frankenphp   (runtime + dev tools: ssh, git, editors, node, composer, mago, mutagen)
knot-frankenscriptling-runtime (frankenphp-runtime + the Scriptling-enabled FrankenPHP binary)
knot-frankenscriptling (frankenphp + the Scriptling-enabled FrankenPHP binary)
knot-adminer      (builds on knot-frankenphp-runtime 8.5, serves Adminer)
knot-mariadb      (standalone, official MariaDB base)
knot-mysql        (standalone, official MySQL base)
knot-postgres     (standalone, official PostgreSQL base)
knot-valkey       (standalone, official Valkey base)
knot-redis        (standalone, official Redis base)
knot-mailpit      (standalone, official Mailpit base)
knot-victoria-logs (standalone, rebased from distroless VictoriaLogs onto Alpine)
```

## How knot uses these images

When a space starts, knot sets environment variables such as `KNOT_SERVER`, `KNOT_USER`, `KNOT_SPACEID` and `KNOT_AGENT_ENDPOINT`. The shared entrypoint:

1. Creates / reuses the runtime user (`KNOT_USER`, uid `1000`) and fixes home ownership.
2. If `KNOT_SERVER` is set, downloads the architecture-appropriate **knot agent** and starts it (with `CAP_NET_BIND_SERVICE`).
3. If the agent is running, starts `rsyslog` in forward-only mode and streams all logs to the agent's syslog port (`KNOT_SYSLOG_PORT`, default `1514`); otherwise `rsyslog` is not started and nothing is written to local log files.
4. Runs every script in `/etc/knot-startup.d/`, then every script in `~/.knot-startup.d/` (user hooks).
5. `exec`s the image's main process (or the supplied command).

The default registry namespace is `docker.io/paularlott`. Pull examples:

```bash
docker pull paularlott/knot-ubuntu:26.04
docker pull paularlott/knot-php:8.5
docker pull paularlott/knot-valkey:9.1
```

All images are multi-arch (`linux/amd64`, `linux/arm64`).

## Building

Builds are driven by [`docker buildx bake`](https://docs.docker.com/build/bake/) via [`docker-bake.hcl`](docker-bake.hcl) and a convenience [`Makefile`](Makefile).

```bash
# Build every target (uses the .env defaults / overrides)
make

# Build a single target (dots are replaced with dashes)
make knot-ubuntu-24-04
make knot-php-8-4
make knot-valkey-9-1-1

# Print the resolved configuration without building
make print

# List all bake targets
make list
```

Version matrices and the image namespace are configurable through environment variables or the `.env` file (see `docker-bake.hcl` for the full list). Notable variables:

| Variable | Purpose |
|----------|---------|
| `TAG_BASE` | Image registry namespace / prefix |
| `CACHE_TAG_BASE` | Separate namespace for the build cache |
| `DOCKER_HUB` | Mirror/pull prefix for upstream images (e.g. a registry cache) |
| `APT_CACHE` | `http://host:3142` apt proxy used during build |
| `UBUNTU_VERSIONS` | Ubuntu versions to build |
| `PHP_VERSIONS` | PHP versions for `knot-php` |
| `FRANKENPHP_VERSIONS` | PHP versions for the FrankenPHP and FrankenScriptling images |
| `PHP_UBUNTU_BASE_VERSION` | Ubuntu base version for `knot-php` |
| `UBUNTU_BASE_VERSION` | Ubuntu base version for the runtime images (`knot-go` / `knot-python` / `knot-node` / `knot-scriptling`) |
| `GO_VERSIONS` | Go versions for `knot-go` |
| `PYTHON_VERSIONS` | Python versions for `knot-python` |
| `NODE_VERSIONS` | Node.js majors for `knot-node` |
| `SCRIPTLING_VERSION` | Scriptling release tag (for the FrankenScriptling images) |
| `SCRIPTLING_VERSIONS` | Scriptling versions for `knot-scriptling` and `knot-scriptling-runtime` |
| `KNOT_ALPINE_VERSIONS` | Alpine versions for `knot-alpine` |
| `KNOT_ALPINE_BASE_VERSION` | Alpine base version for the `knot-scriptling` alpine variant and `knot-scriptling-runtime` |
| `MARIADB_VERSIONS` | MariaDB versions |
| `MYSQL_VERSIONS` | MySQL versions |
| `POSTGRES_VERSIONS` | PostgreSQL versions |
| `VALKEY_VERSIONS` | Valkey versions |
| `REDIS_VERSIONS` | Redis versions |
| `MAILPIT_VERSIONS` | Mailpit versions |
| `VICTORIA_LOGS_VERSIONS` | VictoriaLogs versions |
| `ALPINE_VERSION` | Alpine base version (for `knot-victoria-logs`) |
| `CADDY_VERSION` | Caddy version |
| `FRANKENPHP_VERSION` | FrankenPHP release |

Each target is tagged as `<version>` and, when `BUILD_DATE` is set, also `<version>-<BUILD_DATE>` (the Makefile sets it automatically; a direct `docker buildx bake` without it produces version-only tags). Valkey, Redis and Scriptling additionally get a rolling `major.minor` tag (for the Scriptling alpine variant: `<major.minor>-alpine`).

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Pull requests require the [CLA](CONTRIBUTOR_LICENSE_AGREEMENT.md) to be signed.

## License

The Dockerfiles, scripts and configuration in this repository are [Apache License 2.0](LICENSE.txt). Each base image additionally bundles upstream software (Ubuntu, Redis, MariaDB, Valkey, Caddy, FrankenPHP, …) which retains its own respective license — see each image's README for details.
