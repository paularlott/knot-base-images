# knot-mysql

A [MySQL](https://www.mysql.com/) image for [knot](https://getknot.dev/) spaces. It wraps the official `mysql` image with the knot entrypoint, so a MySQL instance running inside a space gets the same agent integration, `rsyslog` logging and startup hooks as every other knot base image. It is otherwise a standard MySQL container and accepts the usual MySQL environment variables.

## Tags

All tags are multi-arch (`linux/amd64`, `linux/arm64`); see [Docker Hub](https://hub.docker.com/r/paularlott/knot-mysql/tags) for the current list.

Each release is also tagged `<version>-<BUILD_DATE>`.

## Usage

```bash
docker run -d \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=changeme \
  -e KNOT_SERVER=https://knot.example.com \
  -v mysql_data:/var/lib/mysql \
  paularlott/knot-mysql:9.7
```

In a knot space, the root password is typically set from the user's **Service Password**:

```yaml
environment:
  - KNOT_SERVER=${{.server.url}}
  - KNOT_USER=mysql
  - MYSQL_ROOT_PASSWORD=${{.user.service_password}}
```

Connect to the running server (from the host or another space) via knot port forwarding:

```bash
knot forward port 127.0.0.1:3306 <space> 3306
```

## How it works

The image layers the knot entrypoint on top of the official MySQL image. On startup the entrypoint:

1. Forwards `KNOT_USER` to `mysql`.
2. If `KNOT_SERVER` is set, downloads and starts the **knot agent** (as `mysql`).
3. If the agent is running, starts `rsyslog` in forward-only mode and streams logs to the agent's syslog port; otherwise `rsyslog` is not started.
4. Runs scripts in `/etc/knot-startup.d/` and `~/.knot-startup.d/`.
5. `exec`s MySQL's original [`docker-entrypoint.sh`](https://github.com/docker-library/mysql) with `mysqld`.

### MySQL customizations

- **Home directory** — the `mysql` user's home is relocated from `/var/lib/mysql` (the data directory) to `/home/mysql`, so the knot agent's state and user startup hooks live under `/home/mysql/.knot` and `~/.knot-startup.d/` instead of colliding with database files.
- **Local root access** — `/docker-entrypoint-initdb.d/localaccess.sql` clears the `root@localhost` password on first initialisation so that `mysqladmin ping` works for health checks.
- **Data-at-rest encryption** — see [Encryption](#data-at-rest-encryption).

## Data-at-rest encryption

Set `MYSQL_ENCRYPTION_KEY` to a non-empty passphrase to transparently encrypt the database at rest using MySQL's `component_keyring_file` keyring component. When the variable is set, the entrypoint:

1. Loads `component_keyring_file` at startup via a `mysqld.my` manifest, with its keyring data file at `/var/lib/mysql-keyring/keyring` (kept outside the data directory, as required by the component).
2. Writes `/etc/mysql/conf.d/zz-knot-encryption.cnf` that enables `default_table_encryption`, InnoDB redo and undo log encryption, and binary log encryption.
3. Wraps the keyring with the passphrase: the keyring is stored **encrypted** in the data directory (`/var/lib/mysql/.mysql-keyring.enc`) and decrypted to the runtime location on each start; a background loop keeps the encrypted copy up to date as MySQL writes keys. The passphrase itself lives only on tmpfs for the lifetime of the container, so the **persistent volume never holds the plaintext keyring**.

Because the encrypted keyring lives in the data directory (persisted across restarts) and the passphrase is injected at runtime via the environment, a stolen volume alone is useless without the passphrase.

```yaml
environment:
  - MYSQL_ROOT_PASSWORD=${{.user.service_password}}
  - MYSQL_ENCRYPTION_KEY=${{.user.service_password}}
```

**Caveats:**
- The keyring is generated on first initialisation. **Do not change `MYSQL_ENCRYPTION_KEY` afterwards** — MySQL will be unable to decrypt the existing data and refuse to start. Treat the passphrase like any other secret: store it in a password manager / secret provider and keep it stable.
- MySQL Community ships only the file-based `component_keyring_file`; this image wraps it with `openssl` (`AES-256-CBC`) so the keyring is encrypted with the passphrase. The encrypted copy is refreshed every few seconds; a hard crash within a few seconds of first initialisation could lose keys written in that window, so avoid force-killing a space during its first boot.
- This protects data at rest; it is not a substitute for a hardware security module (HSM) or external KMS for regulatory compliance.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KNOT_USER` | `mysql` | Runtime user (forced) |
| `KNOT_SERVER` | _(unset)_ | knot server URL; if set, the agent is started |
| `KNOT_AGENT_ENDPOINT` | _(unset)_ | Agent endpoint reported to the server |
| `KNOT_SPACEID` | _(unset)_ | Space identifier |
| `KNOT_SYSLOG_PORT` | `1514` | Syslog forward target (`0` disables forwarding) |
| `TZ` | `Etc/UTC` | Timezone |
| `MYSQL_ENCRYPTION_KEY` | _(unset)_ | Set to a non-empty passphrase to enable data-at-rest encryption (see below) |

Plus all standard MySQL variables (`MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, …) and MySQL config files mounted under `/etc/mysql/`.

## Exposed ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `3306` | TCP | MySQL |

## Volumes

- **`/var/lib/mysql`** — the MySQL data directory; persist this across restarts.

## License

MySQL is [GPLv2 with FOSS Exception](https://www.mysql.com/about/legal/licensing/oem/). This image's packaging — the Dockerfile, `knot-entrypoint` and supporting scripts/configs — is [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Source: [paularlott/knot-base-images](https://github.com/paularlott/knot-base-images).
