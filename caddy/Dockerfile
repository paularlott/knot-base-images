ARG IMAGE_VERSION
ARG DOCKER_HUB

FROM ${DOCKER_HUB}library/golang:1.25.1-alpine AS builder

ARG IMAGE_VERSION
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
  apk update \
  && apk add openssh git \
  && mkdir -p -m 0600 ~/.ssh \
  && ssh-keyscan github.com >> ~/.ssh/known_hosts \
  && git config --global url.git@github.com:.insteadOf https://github.com/ \
  && go env -w GOCACHE=/root/.cache/go-build \
  && go env -w GOMODCACHE=/go/pkg/mod \
  \
  && go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest \
  \
  && xcaddy build v${IMAGE_VERSION} \
    --output /usr/bin/caddy \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/pteich/caddy-tlsconsul \
    --with github.com/caddyserver/transform-encoder

## Build the runtime image
FROM alpine:3.20

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN set -eux \
  && apk add --no-cache ca-certificates libcap mailcap \
	&& mkdir -p \
    /config/caddy \
    /data/caddy \
    /etc/caddy \
    /usr/share/caddy \
  \
  && wget -O /etc/caddy/Caddyfile "https://github.com/caddyserver/dist/raw/509c30cecd3cbc4012f6b1cc88d8f3f000fb06e4/config/Caddyfile" \
  && wget -O /usr/share/caddy/index.html "https://github.com/caddyserver/dist/raw/509c30cecd3cbc4012f6b1cc88d8f3f000fb06e4/welcome/index.html" \
  && setcap cap_net_bind_service=+ep /usr/bin/caddy \
  && chmod +x /usr/bin/caddy \
  && caddy version

# https://github.com/caddyserver/caddy/releases
ENV CADDY_VERSION=v2.9.1

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_CONFIG_HOME=/config
ENV XDG_DATA_HOME=/data

LABEL org.opencontainers.image.version=v2.9.1
LABEL org.opencontainers.image.title=Caddy
LABEL org.opencontainers.image.description="a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go"
LABEL org.opencontainers.image.url=https://caddyserver.com
LABEL org.opencontainers.image.documentation=https://caddyserver.com/docs
LABEL org.opencontainers.image.vendor="knot"
LABEL org.opencontainers.image.licenses=Apache-2.0
LABEL org.opencontainers.image.source="https://github.com/caddyserver/caddy-docker"

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

WORKDIR /srv

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
