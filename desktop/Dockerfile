ARG DOCKER_HUB
ARG IMAGE_VERSION
ARG IMAGE_BASE

FROM paularlott/knot-base-${IMAGE_BASE}:${IMAGE_VERSION}

LABEL org.opencontainers.image.source=https://github.com/paularlott/knot-base-images
LABEL org.opencontainers.image.description="Base container"

ENV DEBIAN_FRONTEND=noninteractive \
  # This allows epiphany to run in the container
  WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1

ARG APT_CACHE=${APT_CACHE}

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
  && chmod g+r /etc/ssl/private/

RUN apt-get update -y \
  && apt-get install -y xfce4 xfce4-terminal xterm xfce4-goodies dbus-x11 epiphany-browser \
  \
  # Remove the power manager plugin to avoid errors, screensaver to avoid blanking
  && apt-get purge -y pm-utils xscreensaver* xfce4-power-manager xfce4-screensaver

# Get the OS and if debian install chromium otherwise install chromium-browser after adding saiarcot895/chromium-beta repository
RUN OS=$(lsb_release -si); \
  if [ "$OS" = "Debian" ]; then apt-get install -y chromium; \
  else add-apt-repository ppa:saiarcot895/chromium-beta; apt-get install -y chromium-browser; fi

COPY files/knot-startup.d/ /etc/knot-startup.d/
COPY files/xfce-perchannel-xml/ /usr/share/assets/xfce-perchannel-xml/
# https://www.pexels.com/photo/grayscale-photo-of-a-forest-5388521/
COPY files/backgrounds/ /usr/share/backgrounds/
ADD https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic-darker.tar.xz /usr/share/assets/

RUN ARCH=$(uname -m); \
  CODENAME=$(lsb_release -cs); \
  KASMVNC_VERSION=1.2.0; \
	case "$ARCH" in \
		'x86_64') url="https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/kasmvncserver_${CODENAME}_${KASMVNC_VERSION}_amd64.deb";; \
		'aarch64') url="https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/kasmvncserver_${CODENAME}_${KASMVNC_VERSION}_arm64.deb";; \
		*) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
	esac; \
  wget -O "/tmp/kasmvncserver.deb" "$url"; \
	dpkg -i /tmp/kasmvncserver.deb; \
  rm /tmp/kasmvncserver.deb; \
  chmod +r /usr/share/assets/* /usr/share/backgrounds/*

# docker run --privileged --rm -it -p 5680:5680 ghcr.io/paularlott/knot-base-ubuntu-desktop:22.04 bash
# docker run --cap-add SYS_ADMIN --rm -it -p 5680:5680 -e KNOT_SERVICE_PASSWORD=testing ghcr.io/paularlott/knot-base-debian-desktop:12 bash

# For chrome
# sudo dbus-daemon --system

# chromium flags
# echo "CHROMIUM_FLAGS='--no-sandbox --disable-gpu --user-data-dir --disable-features=dbus" > "${HOME}"/.chromium-browser.init

#--headless --no-sandbox --disable-gpu --disable-features=dbus

### Set the username and password for vncserver
# echo -e "testing\ntesting\n" | vncpasswd -u knot -w -r

### Start the vncserver with the xfce desktop
# vncserver :1 -websocketPort 5680 -interface 0.0.0.0 -select-de xfce

### disable screen saver and power management
# DISPLAY=:1 xset s noblank; DISPLAY=:1 xset s off

# https://localhost:5680/

# TODO
# /usr/local/share/assets/
# Download https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic-darker.tar.xz to ~/.themes and write in config if it's not already done
# Download https://www.pexels.com/photo/grayscale-photo-of-a-forest-5388521/ to /usr/share/backgrounds and write in config if it's not already done
