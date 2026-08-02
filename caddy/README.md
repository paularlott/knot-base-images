# knot-caddy

A [Caddy](https://caddyserver.com/) web server image built from source with [`xcaddy`](https://github.com/caddyserver/xcaddy), bundling a set of useful modules. It is primarily a **build-time dependency** for the `knot-php` image (which copies the Caddy binary into its own image), but it also works as a standalone reverse proxy / web server. Part of the [knot](https://getknot.dev/) base images.

The binary is cross-compiled for both `linux/amd64` and `linux/arm64` during a single build, then the correct one is selected for the target platform.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-caddy/tags) for the current list.

Each release is also tagged `<version>-<BUILD_DATE>`.

## Bundled Caddy modules

In addition to Caddy's standard modules, the binary is built with:

- [`caddy-dns/cloudflare`](https://github.com/caddy-dns/cloudflare) — Cloudflare DNS-01 challenge for automatic HTTPS.
- [`pteich/caddy-tlsconsul`](https://github.com/pteich/caddy-tlsconsul) — store TLS certificates in Consul.
- [`caddyserver/transform-encoder`](https://github.com/caddyserver/transform-encoder) — transform log entries.

## Usage

```bash
docker run -d \
  -p 80:80 -p 443:443 -p 443:443/udp -p 2019:2019 \
  -v caddy_config:/config -v caddy_data:/data \
  paularlott/knot-caddy:2.11.4
```

Mount your own `Caddyfile` at `/etc/caddy/Caddyfile` to configure sites. The default command runs Caddy with the bundled base config:

```
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
```

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `80` | TCP | HTTP |
| `443` | TCP | HTTPS |
| `443` | UDP | HTTP/3 |
| `2019` | TCP | Caddy admin API |

## Volumes

- **`/config`** — Caddy configuration state (`XDG_CONFIG_HOME`).
- **`/data`** — Caddy data/certificates (`XDG_DATA_HOME`).

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `XDG_CONFIG_HOME` | `/config` | Where Caddy stores its config |
| `XDG_DATA_HOME` | `/data` | Where Caddy stores data / certs |

## License

Caddy is [Apache 2.0](https://github.com/caddyserver/caddy/blob/master/LICENSE.txt). This image's packaging (Dockerfile and config) is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
