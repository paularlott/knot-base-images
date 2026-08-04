# knot-python

A [Python](https://www.python.org/) development image for [knot](https://getknot.dev/) spaces, combining `knot-ubuntu` with the Python interpreter, `pip`, and the [uv](https://github.com/astral-sh/uv) package manager. It is a pure runtime image — no web server — so you run your own process or app server (e.g. `uvicorn`, `gunicorn`).

It inherits the full knot entrypoint, runtime user, `rsyslog` logging and startup-hook framework from `knot-ubuntu`.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-python/tags) for the current list.

Python is installed from the Ubuntu 26.04 archive; the `<version>` tag is the Python major.minor (e.g. `3.14`). Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -e KNOT_SERVER=https://knot.example.com \
  -e KNOT_USER=alice \
  -v knot_home:/home \
  paularlott/knot-python:3.14
```

Then, in the space:

```bash
python -m venv .venv && . .venv/bin/activate
pip install httpx
python -c 'import httpx; print(httpx.__version__)'
```

Or with [uv](https://docs.astral.sh/uv/):

```bash
uv init app && cd app && uv run python main.py
```

## How it works

Builds on `knot-ubuntu:26.04`, which ships Python 3.14 in its archive. `python3.14`, `-venv` and `-dev` are installed, and `python` / `python3` are symlinked (in `/usr/local/bin`, ahead of `/usr/bin`) to the chosen version without disturbing system tooling that calls `/usr/bin/python3`. `pip` is upgraded, and `uv` is installed system-wide.

## Environment variables

Built on `knot-ubuntu`, so it supports the common knot variables (`KNOT_USER`, `KNOT_SERVER`, `KNOT_SPACEID`, `KNOT_SYSLOG_PORT`, `TZ`, …).

Python-specific:

| Variable | Default | Description |
|----------|---------|-------------|
| `PYTHON_VERSION` | _(build-time)_ | The Python major.minor (e.g. `3.14`) |

## Volumes

- **`/home`** — persistent home directory; virtualenvs and projects live here.

## License

Python is [PSF License](https://docs.python.org/3/license.html). This image's packaging — the Dockerfile and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
