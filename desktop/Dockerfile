ARG DOCKER_HUB=
ARG IMAGE_VERSION=latest
ARG IMAGE_BASE=ubuntu
ARG TAG_BASE=paularlott

FROM ${TAG_BASE}/knot-${IMAGE_BASE}:${IMAGE_VERSION}

ENV DEBIAN_FRONTEND=noninteractive \
  # This allows epiphany to run in the container
  WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1

ARG APT_CACHE
ARG KASMVNC_VERSION=

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get install -y \
    libswitch-perl \
    libyaml-tiny-perl \
    libhash-merge-simple-perl \
    liblist-moreutils-perl \
    libdatetime-timezone-perl \
    libnss-wrapper \
    libjpeg-dev \
    xfce4 \
    xfce4-terminal \
    xterm \
    xfce4-goodies \
    dbus-x11 \
    epiphany-browser \
  && chmod g+r /etc/ssl/private/ \
  # Remove the power manager plugin to avoid errors, screensaver to avoid blanking
  && apt-get purge -y pm-utils xscreensaver* xfce4-power-manager xfce4-screensaver \
  \
  # Install flatpak and chromium (we use the flatpak version as more stable in docker)
  && apt-get install -y flatpak \
  && flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo \
  && flatpak install -y org.chromium.Chromium \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi

COPY files/knot-startup.d/ /etc/knot-startup.d/
COPY files/xfce-perchannel-xml/ /usr/share/assets/xfce-perchannel-xml/

# Set default app and expose chromium
COPY files/misc/helpers.rc /usr/share/assets/
COPY files/misc/chromium /usr/local/bin/

# https://www.pexels.com/photo/grayscale-photo-of-a-forest-5388521/
COPY files/backgrounds/ /usr/share/backgrounds/
ADD https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic-darker.tar.xz /usr/share/assets/

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  set -e; \
  ARCH=$(uname -m); \
  CODENAME=$(lsb_release -cs); \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi; \
  if [ -z "$KASMVNC_VERSION" ]; then \
    KASMVNC_VERSION=$(wget -qO- https://api.github.com/repos/kasmtech/KasmVNC/releases/latest \
      | jq -r '.tag_name | ltrimstr("v")'); \
  fi; \
  if [ -z "$KASMVNC_VERSION" ]; then echo >&2 "error: could not determine KasmVNC version"; exit 1; fi; \
  case "$CODENAME" in \
    focal|jammy|noble) ;; \
    *) echo >&2 "warning: no native KasmVNC build for '$CODENAME', falling back to noble"; CODENAME="noble";; \
  esac; \
  case "$ARCH" in \
    'x86_64')  url="https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/kasmvncserver_${CODENAME}_${KASMVNC_VERSION}_amd64.deb";; \
    'aarch64') url="https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/kasmvncserver_${CODENAME}_${KASMVNC_VERSION}_arm64.deb";; \
    *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
  esac; \
  echo "Installing KasmVNC ${KASMVNC_VERSION} (${CODENAME})"; \
  wget -O "/tmp/kasmvncserver.deb" "$url"; \
  apt-get update -y; \
  apt-get install -y /tmp/kasmvncserver.deb; \
  rm /tmp/kasmvncserver.deb; \
  if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi; \
  chmod +r /usr/share/assets/* /usr/share/backgrounds/*
