ARG DOCKER_HUB=
ARG IMAGE_VERSION=26.04
ARG IMAGE_BASE=ubuntu
ARG TAG_BASE=paularlott
ARG PYTHON_VERSION=3.14

FROM ${TAG_BASE}/knot-${IMAGE_BASE}:${IMAGE_VERSION}

ARG APT_CACHE
ARG PYTHON_VERSION
ENV PYTHON_VERSION=${PYTHON_VERSION}

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get install -y \
    python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev \
    python3-pip build-essential libssl-dev libffi-dev \
  \
  # make this Python the default `python` / `python3` (in /usr/local/bin,
  # ahead of /usr/bin, so system scripts using /usr/bin/python3 are unaffected)
  && ln -sf /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python${PYTHON_VERSION} \
  && ln -sf /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python3 \
  && ln -sf /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python \
  # PEP 668: drop the "externally-managed" marker so `pip install` works in this
  # dev image (users still encouraged to use venvs / uv)
  && rm -f /usr/lib/python3*/EXTERNALLY-MANAGED \
  \
  # uv - fast Python package manager (https://github.com/astral-sh/uv)
  && curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi
