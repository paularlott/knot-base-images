# =============================================================================
# Variables: no defaults here on purpose. The Makefile is the one place that
# sets versions and registries and exports them; a bare `docker buildx bake`
# fails with the messages below instead of silently building stale versions.
# =============================================================================
variable "TAG_BASE" {
  validation {
    condition     = TAG_BASE != ""
    error_message = "TAG_BASE is not set: build through the Makefile, which exports it."
  }
}

# Optional: empty means not used (CACHE_TAG_BASE falls back to TAG_BASE).
variable "CACHE_TAG_BASE" {}
variable "DOCKER_HUB" {}
variable "APT_CACHE" {}
variable "BUILD_DATE" {}

# The knot runtime essentials and dev CLI set, defined once and consumed by
# every Debian-family image (ubuntu-runtime, frankenphp-runtime, knot-ubuntu,
# knot-frankenphp). Per-image extras (db clients, Sury prerequisites, mago,
# composer, node, …) are appended in the individual Dockerfiles. Alpine images
# use different package names and keep their own lists.
variable "APT_RUNTIME_PACKAGES" {
  default = "tzdata locales procps cron logrotate rsyslog sudo ssl-cert curl unzip uuid-runtime libcap2-bin"
}

variable "APT_DEV_PACKAGES" {
  default = "openssh-client openssh-server fish iputils-ping htop iproute2 iftop git vim wget screen dnsutils gnupg2 nano tmux bat ripgrep fzf zoxide make direnv gettext-base valkey-tools jq"
}

variable "PHP_UBUNTU_BASE_VERSION" {
  validation {
    condition     = PHP_UBUNTU_BASE_VERSION != ""
    error_message = "PHP_UBUNTU_BASE_VERSION is not set: build through the Makefile, which exports it."
  }
}

variable "UBUNTU_BASE_VERSION" {
  validation {
    condition     = UBUNTU_BASE_VERSION != ""
    error_message = "UBUNTU_BASE_VERSION is not set: build through the Makefile, which exports it."
  }
}

variable "CADDY_VERSION" {
  validation {
    condition     = CADDY_VERSION != ""
    error_message = "CADDY_VERSION is not set: build through the Makefile, which exports it."
  }
}

variable "KNOT_ALPINE_BASE_VERSION" {
  validation {
    condition     = KNOT_ALPINE_BASE_VERSION != ""
    error_message = "KNOT_ALPINE_BASE_VERSION is not set: build through the Makefile, which exports it."
  }
}

variable "VMAUTH_VERSION" {
  validation {
    condition     = VMAUTH_VERSION != ""
    error_message = "VMAUTH_VERSION is not set: build through the Makefile, which exports it."
  }
}

variable "ALPINE_VERSION" {
  validation {
    condition     = ALPINE_VERSION != ""
    error_message = "ALPINE_VERSION is not set: build through the Makefile, which exports it."
  }
}

# FRANKENPHP_VERSIONS and FRANKENSCRIPTLING_VERSIONS are PHP lines (8.5, …):
# the images build on dunglas/frankenphp:php<x.y> and
# ${TAG_BASE}/frankenscriptling:php<x.y> and are tagged <x.y>.
variable "UBUNTU_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(UBUNTU_VERSIONS) > 0
    error_message = "UBUNTU_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

# Go toolchain the images build with (knot-caddy, the FrankenPHP builder).
variable "GO_BUILD_VERSION" {
  validation {
    condition     = GO_BUILD_VERSION != ""
    error_message = "GO_BUILD_VERSION is not set: build through the Makefile, which exports it."
  }
}

variable "GO_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(GO_VERSIONS) > 0
    error_message = "GO_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "PYTHON_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(PYTHON_VERSIONS) > 0
    error_message = "PYTHON_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "NODE_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(NODE_VERSIONS) > 0
    error_message = "NODE_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "PHP_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(PHP_VERSIONS) > 0
    error_message = "PHP_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "FRANKENPHP_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(FRANKENPHP_VERSIONS) > 0
    error_message = "FRANKENPHP_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "SCRIPTLING_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(SCRIPTLING_VERSIONS) > 0
    error_message = "SCRIPTLING_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "FRANKENSCRIPTLING_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(FRANKENSCRIPTLING_VERSIONS) > 0
    error_message = "FRANKENSCRIPTLING_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "ADMINER_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(ADMINER_VERSIONS) > 0
    error_message = "ADMINER_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "KNOT_ALPINE_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(KNOT_ALPINE_VERSIONS) > 0
    error_message = "KNOT_ALPINE_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "MARIADB_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(MARIADB_VERSIONS) > 0
    error_message = "MARIADB_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "MYSQL_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(MYSQL_VERSIONS) > 0
    error_message = "MYSQL_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "POSTGRES_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(POSTGRES_VERSIONS) > 0
    error_message = "POSTGRES_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "VALKEY_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(VALKEY_VERSIONS) > 0
    error_message = "VALKEY_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "REDIS_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(REDIS_VERSIONS) > 0
    error_message = "REDIS_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "MAILPIT_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(MAILPIT_VERSIONS) > 0
    error_message = "MAILPIT_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

variable "VICTORIA_LOGS_VERSIONS" {
  type = list(string)
  validation {
    condition     = length(VICTORIA_LOGS_VERSIONS) > 0
    error_message = "VICTORIA_LOGS_VERSIONS is not set: build through the Makefile, which exports it as a comma-separated list."
  }
}

# =============================================================================
# Helper functions and shared target
# =============================================================================

function "cache_base" {
  params = []
  result = CACHE_TAG_BASE == "" ? TAG_BASE : CACHE_TAG_BASE
}

# The newest PHP line in FRANKENPHP_VERSIONS (listed oldest first), for images
# that only build on one, such as knot-adminer.
function "frankenphp_latest" {
  params = []
  result = FRANKENPHP_VERSIONS[length(FRANKENPHP_VERSIONS) - 1]
}

function "major_minor" {
  params = [version]
  result = "${split(".", version)[0]}.${split(".", version)[1]}"
}

# An image's tag list: the plain version tag, plus a `<version>-<BUILD_DATE>`
# tag only when BUILD_DATE is set. BUILD_DATE is exported by the Makefile;
# invoking bake directly leaves it empty, which must not produce tags with a
# dangling trailing dash.
function "version_tags" {
  params = [repo, version]
  result = flatten([
    "${TAG_BASE}/${repo}:${version}",
    BUILD_DATE == "" ? [] : ["${TAG_BASE}/${repo}:${version}-${BUILD_DATE}"],
  ])
}

# One registry build-cache ref per image, shared by the pull/push pair so
# they cannot drift apart.
function "cache_ref" {
  params = [repo, version]
  result = "${cache_base()}/${repo}:buildcache-${version}"
}

function "cache_from" {
  params = [repo, version]
  result = [{
    type = "registry"
    ref  = cache_ref(repo, version)
  }]
}

function "cache_to" {
  params = [repo, version]
  result = [{
    type              = "registry"
    ref               = cache_ref(repo, version)
    mode              = "max"
    "oci-media-types" = true
    "image-manifest"  = true
  }]
}

target "_common" {
  platforms = ["linux/amd64", "linux/arm64"]
  output    = [{ type = "image", push = true }]

  labels = {
    "org.opencontainers.image.vendor"  = "Paul Arlott"
    "org.opencontainers.image.source"  = "https://github.com/paularlott/knot-base-images"
    "org.opencontainers.image.created" = "${BUILD_DATE}"
  }
}

# =============================================================================
# Groups
# =============================================================================

group "default" {
  targets = [
    "knot-ubuntu-runtime",
    "knot-ubuntu",
    "knot-alpine-runtime",
    "knot-alpine",
    "knot-caddy",
    "knot-php",
    "knot-frankenphp-runtime",
    "knot-frankenphp",
    "knot-frankenscriptling-runtime",
    "knot-frankenscriptling",
    "knot-adminer",
    "knot-ubuntu-desktop",
    "knot-valkey",
    "knot-mariadb",
    "knot-mysql",
    "knot-postgres",
    "knot-redis",
    "knot-mailpit",
    "knot-victoria-logs",
    "knot-go",
    "knot-python",
    "knot-node",
    "knot-scriptling-runtime",
    "knot-scriptling",
    "knot-scriptling-alpine",
  ]
}

# =============================================================================
# Targets
# =============================================================================

target "knot-ubuntu-runtime" {
  name        = "knot-ubuntu-runtime-${replace(version, ".", "-")}"
  description = "Minimal Ubuntu base image with the knot toolchain, no dev tools"
  matrix      = { version = UBUNTU_VERSIONS }
  inherits    = ["_common"]
  context     = "./ubuntu-runtime"

  labels = {
    "org.opencontainers.image.title"       = "Knot Ubuntu Runtime"
    "org.opencontainers.image.description" = "Minimal Ubuntu base with the knot toolchain, no dev tools"
    "org.opencontainers.image.version"     = "${version}"
  }

  args = {
    IMAGE_BASE           = "ubuntu"
    IMAGE_VERSION        = "${version}"
    DOCKER_HUB           = "${DOCKER_HUB}"
    APT_CACHE            = "${APT_CACHE}"
    APT_RUNTIME_PACKAGES = "${APT_RUNTIME_PACKAGES}"
  }

  tags = version_tags("knot-ubuntu-runtime", version)

  cache-from = cache_from("knot-ubuntu-runtime", "${version}")
  cache-to   = cache_to("knot-ubuntu-runtime", "${version}")
}

target "knot-ubuntu" {
  name        = "knot-ubuntu-${replace(version, ".", "-")}"
  description = "Base Ubuntu image with knot startup scripts"
  matrix      = { version = UBUNTU_VERSIONS }
  inherits    = ["_common"]
  context     = "./ubuntu"

  labels = {
    "org.opencontainers.image.title"       = "Knot Ubuntu"
    "org.opencontainers.image.description" = "Base Ubuntu image with knot startup scripts"
    "org.opencontainers.image.version"     = "${version}"
  }

  contexts = {
    "${TAG_BASE}/knot-ubuntu-runtime:${version}" = "target:knot-ubuntu-runtime-${replace(version, ".", "-")}"
  }

  args = {
    IMAGE_BASE        = "ubuntu"
    IMAGE_VERSION     = "${version}"
    DOCKER_HUB        = "${DOCKER_HUB}"
    APT_CACHE         = "${APT_CACHE}"
    TAG_BASE          = "${TAG_BASE}"
    APT_DEV_PACKAGES  = "${APT_DEV_PACKAGES}"
  }

  tags = version_tags("knot-ubuntu", version)

  cache-from = cache_from("knot-ubuntu", "${version}")
  cache-to   = cache_to("knot-ubuntu", "${version}")
}

target "knot-alpine-runtime" {
  name        = "knot-alpine-runtime-${replace(version, ".", "-")}"
  description = "Minimal Alpine base image with the knot toolchain, no dev tools"
  matrix      = { version = KNOT_ALPINE_VERSIONS }
  inherits    = ["_common"]
  context     = "./alpine-runtime"

  labels = {
    "org.opencontainers.image.title"       = "Knot Alpine Runtime"
    "org.opencontainers.image.description" = "Minimal Alpine base with the knot toolchain, no dev tools"
    "org.opencontainers.image.version"     = "${version}"
  }

  args = {
    ALPINE_VERSION = "${version}"
    DOCKER_HUB     = "${DOCKER_HUB}"
  }

  tags = version_tags("knot-alpine-runtime", version)

  cache-from = cache_from("knot-alpine-runtime", "${version}")
  cache-to   = cache_to("knot-alpine-runtime", "${version}")
}

target "knot-alpine" {
  name        = "knot-alpine-${replace(version, ".", "-")}"
  description = "Base Alpine image with knot startup scripts"
  matrix      = { version = KNOT_ALPINE_VERSIONS }
  inherits    = ["_common"]
  context     = "./alpine"

  labels = {
    "org.opencontainers.image.title"       = "Knot Alpine"
    "org.opencontainers.image.description" = "Base Alpine image with knot startup scripts"
    "org.opencontainers.image.version"     = "${version}"
  }

  contexts = {
    "${TAG_BASE}/knot-alpine-runtime:${version}" = "target:knot-alpine-runtime-${replace(version, ".", "-")}"
  }

  args = {
    ALPINE_VERSION = "${version}"
    DOCKER_HUB     = "${DOCKER_HUB}"
    TAG_BASE       = "${TAG_BASE}"
  }

  tags = version_tags("knot-alpine", version)

  cache-from = cache_from("knot-alpine", "${version}")
  cache-to   = cache_to("knot-alpine", "${version}")
}

target "knot-caddy" {
  description = "Caddy server image (used as base for PHP containers)"
  inherits    = ["_common"]
  context     = "./caddy"

  labels = {
    "org.opencontainers.image.title"       = "Knot Caddy"
    "org.opencontainers.image.description" = "Caddy server image with xcaddy-built binary"
    "org.opencontainers.image.version"     = "${CADDY_VERSION}"
  }

  args = {
    IMAGE_VERSION    = "${CADDY_VERSION}"
    DOCKER_HUB       = "${DOCKER_HUB}"
    GO_BUILD_VERSION = "${GO_BUILD_VERSION}"
  }

  tags = version_tags("knot-caddy", CADDY_VERSION)

  cache-from = cache_from("knot-caddy", "${CADDY_VERSION}")
  cache-to   = cache_to("knot-caddy", "${CADDY_VERSION}")
}

target "knot-ubuntu-desktop" {
  name        = "knot-ubuntu-desktop-${replace(version, ".", "-")}"
  description = "Ubuntu desktop image with XFCE served via KasmVNC"
  matrix      = { version = UBUNTU_VERSIONS }
  inherits    = ["_common"]
  context     = "./desktop"

  labels = {
    "org.opencontainers.image.title"       = "Knot Desktop"
    "org.opencontainers.image.description" = "Ubuntu desktop image with XFCE served via KasmVNC"
    "org.opencontainers.image.version"     = "${version}"
  }

  contexts = {
    "${TAG_BASE}/knot-ubuntu:${version}" = "target:knot-ubuntu-${replace(version, ".", "-")}"
  }

  args = {
    IMAGE_BASE    = "ubuntu"
    IMAGE_VERSION = "${version}"
    DOCKER_HUB    = "${DOCKER_HUB}"
    APT_CACHE     = "${APT_CACHE}"
    TAG_BASE      = "${TAG_BASE}"
  }

  tags = version_tags("knot-desktop", version)

  cache-from = cache_from("knot-desktop", "${version}")
  cache-to   = cache_to("knot-desktop", "${version}")
}

target "knot-php" {
  name        = "knot-php-${replace(php, ".", "-")}"
  description = "Ubuntu + Caddy + PHP image"
  matrix      = {
    php = PHP_VERSIONS
  }
  inherits    = ["_common"]
  context     = "./php"

  labels = {
    "org.opencontainers.image.title"       = "Knot PHP"
    "org.opencontainers.image.description" = "Ubuntu + Caddy + PHP image"
    "org.opencontainers.image.version"     = "${php}"
  }

  contexts = {
    "${TAG_BASE}/knot-caddy:${CADDY_VERSION}"            = "target:knot-caddy"
    "${TAG_BASE}/knot-ubuntu:${PHP_UBUNTU_BASE_VERSION}" = "target:knot-ubuntu-${replace(PHP_UBUNTU_BASE_VERSION, ".", "-")}"
  }

  args = {
    IMAGE_BASE    = "ubuntu"
    IMAGE_VERSION = "${PHP_UBUNTU_BASE_VERSION}"
    DOCKER_HUB    = "${DOCKER_HUB}"
    APT_CACHE     = "${APT_CACHE}"
    TAG_BASE      = "${TAG_BASE}"
    CADDY_VERSION = "${CADDY_VERSION}"
    PHP_VERSION   = "${php}"
  }

  tags = version_tags("knot-php", php)

  cache-from = cache_from("knot-php", "${php}")
  cache-to   = cache_to("knot-php", "${php}")
}

target "knot-frankenphp-runtime" {
  name        = "knot-frankenphp-runtime-${replace(php, ".", "-")}"
  description = "FrankenPHP runtime image without dev tooling"
  matrix      = {
    php = FRANKENPHP_VERSIONS
  }
  inherits    = ["_common"]
  context     = "./frankenphp-runtime"
  target      = "frankenphp"

  labels = {
    "org.opencontainers.image.title"       = "Knot FrankenPHP Runtime"
    "org.opencontainers.image.description" = "FrankenPHP runtime with knot startup tooling, no dev tools"
    "org.opencontainers.image.version"     = "${php}"
  }

  args = {
    APT_CACHE            = "${APT_CACHE}"
    PHP_VERSION          = "${php}"
    APT_RUNTIME_PACKAGES = "${APT_RUNTIME_PACKAGES}"
    GO_BUILD_VERSION     = "${GO_BUILD_VERSION}"
  }

  tags = version_tags("knot-frankenphp-runtime", php)

  cache-from = cache_from("knot-frankenphp-runtime", "${php}")
  cache-to   = cache_to("knot-frankenphp-runtime", "${php}")
}

target "knot-frankenphp" {
  name        = "knot-frankenphp-${replace(php, ".", "-")}"
  description = "FrankenPHP runtime plus development tools"
  matrix      = {
    php = FRANKENPHP_VERSIONS
  }
  inherits    = ["_common"]
  context     = "./frankenphp"

  labels = {
    "org.opencontainers.image.title"       = "Knot FrankenPHP"
    "org.opencontainers.image.description" = "FrankenPHP image with knot startup tooling and dev tools"
    "org.opencontainers.image.version"     = "${php}"
  }

  contexts = {
    "${TAG_BASE}/knot-frankenphp-runtime:${php}" = "target:knot-frankenphp-runtime-${replace(php, ".", "-")}"
  }

  args = {
    APT_CACHE        = "${APT_CACHE}"
    PHP_VERSION      = "${php}"
    TAG_BASE         = "${TAG_BASE}"
    APT_DEV_PACKAGES = "${APT_DEV_PACKAGES}"
  }

  tags = version_tags("knot-frankenphp", php)

  cache-from = cache_from("knot-frankenphp", "${php}")
  cache-to   = cache_to("knot-frankenphp", "${php}")
}

target "knot-frankenscriptling-runtime" {
  name        = "knot-frankenscriptling-runtime-${replace(php, ".", "-")}"
  description = "FrankenPHP with the Scriptling PHP extension, without dev tooling"
  matrix      = {
    php = FRANKENSCRIPTLING_VERSIONS
  }
  inherits    = ["_common"]
  # The knot-frankenphp-runtime Dockerfile, on the frankenscriptling image
  context     = "./frankenphp-runtime"
  target      = "frankenscriptling"

  labels = {
    "org.opencontainers.image.title"       = "Knot FrankenScriptling Runtime"
    "org.opencontainers.image.description" = "FrankenPHP runtime with the Scriptling PHP extension, no dev tools"
    "org.opencontainers.image.version"     = "${php}"
  }

  args = {
    APT_CACHE            = "${APT_CACHE}"
    PHP_VERSION          = "${php}"
    APT_RUNTIME_PACKAGES = "${APT_RUNTIME_PACKAGES}"
    GO_BUILD_VERSION     = "${GO_BUILD_VERSION}"
    BASE_IMAGE           = "${TAG_BASE}/frankenscriptling:php${php}"
  }

  tags = version_tags("knot-frankenscriptling-runtime", php)

  cache-from = cache_from("knot-frankenscriptling-runtime", "${php}")
  cache-to   = cache_to("knot-frankenscriptling-runtime", "${php}")
}

target "knot-frankenscriptling" {
  name        = "knot-frankenscriptling-${replace(php, ".", "-")}"
  description = "FrankenPHP with the Scriptling PHP extension plus development tools"
  matrix      = {
    php = FRANKENSCRIPTLING_VERSIONS
  }
  inherits    = ["_common"]
  # The knot-frankenphp (dev layer) Dockerfile, on knot-frankenscriptling-runtime
  context     = "./frankenphp"

  labels = {
    "org.opencontainers.image.title"       = "Knot FrankenScriptling"
    "org.opencontainers.image.description" = "FrankenPHP with the Scriptling PHP extension and dev tools"
    "org.opencontainers.image.version"     = "${php}"
  }

  contexts = {
    "${TAG_BASE}/knot-frankenscriptling-runtime:${php}" = "target:knot-frankenscriptling-runtime-${replace(php, ".", "-")}"
  }

  args = {
    APT_CACHE        = "${APT_CACHE}"
    PHP_VERSION      = "${php}"
    TAG_BASE         = "${TAG_BASE}"
    APT_DEV_PACKAGES = "${APT_DEV_PACKAGES}"
    RUNTIME_IMAGE    = "knot-frankenscriptling-runtime"
  }

  tags = version_tags("knot-frankenscriptling", php)

  cache-from = cache_from("knot-frankenscriptling", "${php}")
  cache-to   = cache_to("knot-frankenscriptling", "${php}")
}

target "knot-adminer" {
  name        = "knot-adminer-${replace(version, ".", "-")}"
  description = "Adminer on knot-frankenphp with Redis, PostgreSQL and MySQL/MariaDB support"
  matrix      = { version = ADMINER_VERSIONS }
  inherits    = ["_common"]
  context     = "./adminer"

  labels = {
    "org.opencontainers.image.title"       = "Knot Adminer"
    "org.opencontainers.image.description" = "Adminer database management on knot-frankenphp"
    "org.opencontainers.image.version"     = "${version}"
  }

  contexts = {
    "${TAG_BASE}/knot-frankenphp-runtime:${frankenphp_latest()}" = "target:knot-frankenphp-runtime-${replace(frankenphp_latest(), ".", "-")}"
  }

  args = {
    ADMINER_VERSION = "${version}"
    TAG_BASE        = "${TAG_BASE}"
    PHP_VERSION     = "${frankenphp_latest()}"
  }

  tags = concat(
    version_tags("knot-adminer", version),
    ["${TAG_BASE}/knot-adminer:latest"],
  )

  cache-from = cache_from("knot-adminer", "${version}")
  cache-to   = cache_to("knot-adminer", "${version}")
}

target "knot-mariadb" {
  name        = "knot-mariadb-${replace(version, ".", "-")}"
  description = "MariaDB image"
  matrix      = { version = MARIADB_VERSIONS }
  inherits    = ["_common"]
  context     = "./mariadb"

  labels = {
    "org.opencontainers.image.title"       = "Knot MariaDB"
    "org.opencontainers.image.description" = "MariaDB image with knot startup tooling"
    "org.opencontainers.image.version"     = "${version}"
  }

  args = {
    DOCKER_HUB      = "${DOCKER_HUB}"
    APT_CACHE       = "${APT_CACHE}"
    MARIADB_VERSION = "${version}"
  }

  tags = version_tags("knot-mariadb", version)

  cache-from = cache_from("knot-mariadb", "${version}")
  cache-to   = cache_to("knot-mariadb", "${version}")
}

target "knot-mysql" {
  name        = "knot-mysql-${replace(version, ".", "-")}"
  description = "MySQL image"
  matrix      = { version = MYSQL_VERSIONS }
  inherits    = ["_common"]
  context     = "./mysql"

  labels = {
    "org.opencontainers.image.title"       = "Knot MySQL"
    "org.opencontainers.image.description" = "MySQL image with knot startup tooling"
    "org.opencontainers.image.version"     = "${version}"
  }

  args = {
    DOCKER_HUB    = "${DOCKER_HUB}"
    MYSQL_VERSION = "${version}"
  }

  tags = version_tags("knot-mysql", version)

  cache-from = cache_from("knot-mysql", "${version}")
  cache-to   = cache_to("knot-mysql", "${version}")
}

target "knot-postgres" {
  name        = "knot-postgres-${replace(version, ".", "-")}"
  description = "PostgreSQL image"
  matrix      = { version = POSTGRES_VERSIONS }
  inherits    = ["_common"]
  context     = "./postgres"

  labels = {
    "org.opencontainers.image.title"       = "Knot PostgreSQL"
    "org.opencontainers.image.description" = "PostgreSQL image with knot startup tooling"
    "org.opencontainers.image.version"     = "${version}"
  }

  args = {
    DOCKER_HUB       = "${DOCKER_HUB}"
    APT_CACHE        = "${APT_CACHE}"
    POSTGRES_VERSION = "${version}"
  }

  tags = version_tags("knot-postgres", version)

  cache-from = cache_from("knot-postgres", "${version}")
  cache-to   = cache_to("knot-postgres", "${version}")
}

target "knot-valkey" {
  name        = "knot-valkey-${replace(version, ".", "-")}"
  description = "Valkey image"
  matrix      = { version = VALKEY_VERSIONS }
  inherits    = ["_common"]
  context     = "./valkey"

  labels = {
    "org.opencontainers.image.title"       = "Knot Valkey"
    "org.opencontainers.image.description" = "Valkey image with knot startup tooling"
    "org.opencontainers.image.version"     = "${version}"
  }

  args = {
    DOCKER_HUB     = "${DOCKER_HUB}"
    APT_CACHE      = "${APT_CACHE}"
    VALKEY_VERSION = "${version}"
  }

  tags = concat(
    version_tags("knot-valkey", version),
    ["${TAG_BASE}/knot-valkey:${major_minor(version)}"],
  )

  cache-from = cache_from("knot-valkey", "${version}")
  cache-to   = cache_to("knot-valkey", "${version}")
}

target "knot-redis" {
  name        = "knot-redis-${replace(version, ".", "-")}"
  description = "Redis image"
  matrix      = { version = REDIS_VERSIONS }
  inherits    = ["_common"]
  context     = "./redis"

  labels = {
    "org.opencontainers.image.title"       = "Knot Redis"
    "org.opencontainers.image.description" = "Redis image with knot startup tooling"
    "org.opencontainers.image.version"     = "${version}"
  }

  args = {
    DOCKER_HUB    = "${DOCKER_HUB}"
    REDIS_VERSION = "${version}"
  }

  tags = concat(
    version_tags("knot-redis", version),
    ["${TAG_BASE}/knot-redis:${major_minor(version)}"],
  )

  cache-from = cache_from("knot-redis", "${version}")
  cache-to   = cache_to("knot-redis", "${version}")
}

target "knot-mailpit" {
  name        = "knot-mailpit-${replace(version, ".", "-")}"
  description = "Mailpit image"
  matrix      = { version = MAILPIT_VERSIONS }
  inherits    = ["_common"]
  context     = "./mailpit"

  labels = {
    "org.opencontainers.image.title"       = "Knot Mailpit"
    "org.opencontainers.image.description" = "Mailpit SMTP mail catcher with knot startup tooling"
    "org.opencontainers.image.version"     = "${version}"
  }

  args = {
    DOCKER_HUB       = "${DOCKER_HUB}"
    MAILPIT_VERSION  = "${version}"
  }

  tags = version_tags("knot-mailpit", version)

  cache-from = cache_from("knot-mailpit", "${version}")
  cache-to   = cache_to("knot-mailpit", "${version}")
}

target "knot-victoria-logs" {
  name        = "knot-victoria-logs-${replace(version, ".", "-")}"
  description = "VictoriaLogs image"
  matrix      = { version = VICTORIA_LOGS_VERSIONS }
  inherits    = ["_common"]
  context     = "./victoria-logs"

  labels = {
    "org.opencontainers.image.title"       = "Knot VictoriaLogs"
    "org.opencontainers.image.description" = "VictoriaLogs log database with knot startup tooling"
    "org.opencontainers.image.version"     = "${version}"
  }

  args = {
    DOCKER_HUB              = "${DOCKER_HUB}"
    VICTORIA_LOGS_VERSION   = "${version}"
    VMAUTH_VERSION          = "${VMAUTH_VERSION}"
    ALPINE_VERSION          = "${ALPINE_VERSION}"
  }

  tags = version_tags("knot-victoria-logs", version)

  cache-from = cache_from("knot-victoria-logs", "${version}")
  cache-to   = cache_to("knot-victoria-logs", "${version}")
}

target "knot-go" {
  name        = "knot-go-${replace(version, ".", "-")}"
  description = "Go runtime image"
  matrix      = { version = GO_VERSIONS }
  inherits    = ["_common"]
  context     = "./go"

  labels = {
    "org.opencontainers.image.title"       = "Knot Go"
    "org.opencontainers.image.description" = "Go runtime image with knot startup tooling"
    "org.opencontainers.image.version"     = "${version}"
  }

  contexts = {
    "${TAG_BASE}/knot-ubuntu:${UBUNTU_BASE_VERSION}" = "target:knot-ubuntu-${replace(UBUNTU_BASE_VERSION, ".", "-")}"
  }

  args = {
    IMAGE_BASE    = "ubuntu"
    IMAGE_VERSION = "${UBUNTU_BASE_VERSION}"
    DOCKER_HUB    = "${DOCKER_HUB}"
    APT_CACHE     = "${APT_CACHE}"
    TAG_BASE      = "${TAG_BASE}"
    GO_VERSION    = "${version}"
  }

  tags = version_tags("knot-go", version)

  cache-from = cache_from("knot-go", "${version}")
  cache-to   = cache_to("knot-go", "${version}")
}

target "knot-python" {
  name        = "knot-python-${replace(version, ".", "-")}"
  description = "Python runtime image"
  matrix      = { version = PYTHON_VERSIONS }
  inherits    = ["_common"]
  context     = "./python"

  labels = {
    "org.opencontainers.image.title"       = "Knot Python"
    "org.opencontainers.image.description" = "Python runtime image with knot startup tooling"
    "org.opencontainers.image.version"     = "${version}"
  }

  contexts = {
    "${TAG_BASE}/knot-ubuntu:${UBUNTU_BASE_VERSION}" = "target:knot-ubuntu-${replace(UBUNTU_BASE_VERSION, ".", "-")}"
  }

  args = {
    IMAGE_BASE     = "ubuntu"
    IMAGE_VERSION  = "${UBUNTU_BASE_VERSION}"
    DOCKER_HUB     = "${DOCKER_HUB}"
    APT_CACHE      = "${APT_CACHE}"
    TAG_BASE       = "${TAG_BASE}"
    PYTHON_VERSION = "${version}"
  }

  tags = version_tags("knot-python", version)

  cache-from = cache_from("knot-python", "${version}")
  cache-to   = cache_to("knot-python", "${version}")
}

target "knot-node" {
  name        = "knot-node-${replace(version, ".", "-")}"
  description = "Node.js runtime image"
  matrix      = { version = NODE_VERSIONS }
  inherits    = ["_common"]
  context     = "./node"

  labels = {
    "org.opencontainers.image.title"       = "Knot Node"
    "org.opencontainers.image.description" = "Node.js runtime image with knot startup tooling"
    "org.opencontainers.image.version"     = "${version}"
  }

  contexts = {
    "${TAG_BASE}/knot-ubuntu:${UBUNTU_BASE_VERSION}" = "target:knot-ubuntu-${replace(UBUNTU_BASE_VERSION, ".", "-")}"
  }

  args = {
    IMAGE_BASE    = "ubuntu"
    IMAGE_VERSION = "${UBUNTU_BASE_VERSION}"
    DOCKER_HUB    = "${DOCKER_HUB}"
    APT_CACHE     = "${APT_CACHE}"
    TAG_BASE      = "${TAG_BASE}"
    NODE_MAJOR    = "${version}"
  }

  tags = version_tags("knot-node", version)

  cache-from = cache_from("knot-node", "${version}")
  cache-to   = cache_to("knot-node", "${version}")
}

target "knot-scriptling-runtime" {
  name        = "knot-scriptling-runtime-${replace(version, ".", "-")}"
  description = "Scriptling runtime image (Alpine, no dev tooling)"
  matrix      = { version = SCRIPTLING_VERSIONS }
  inherits    = ["_common"]
  context     = "./scriptling-runtime"

  labels = {
    "org.opencontainers.image.title"       = "Knot Scriptling Runtime"
    "org.opencontainers.image.description" = "Scriptling runtime with knot startup tooling, no dev tools"
    "org.opencontainers.image.version"     = "${version}"
  }

  contexts = {
    "${TAG_BASE}/knot-alpine-runtime:${KNOT_ALPINE_BASE_VERSION}" = "target:knot-alpine-runtime-${replace(KNOT_ALPINE_BASE_VERSION, ".", "-")}"
  }

  args = {
    ALPINE_VERSION     = "${KNOT_ALPINE_BASE_VERSION}"
    SCRIPTLING_VERSION = "v${version}"
    TAG_BASE           = "${TAG_BASE}"
  }

  tags = concat(
    version_tags("knot-scriptling-runtime", version),
    [
      "${TAG_BASE}/knot-scriptling-runtime:${major_minor(version)}",
      "${TAG_BASE}/knot-scriptling-runtime:latest",
    ],
  )

  cache-from = cache_from("knot-scriptling-runtime", "${version}")
  cache-to   = cache_to("knot-scriptling-runtime", "${version}")
}

target "knot-scriptling" {
  name        = "knot-scriptling-${replace(version, ".", "-")}"
  description = "Scriptling runtime image"
  matrix      = { version = SCRIPTLING_VERSIONS }
  inherits    = ["_common"]
  context     = "./scriptling"

  labels = {
    "org.opencontainers.image.title"       = "Knot Scriptling"
    "org.opencontainers.image.description" = "Scriptling runtime image with knot startup tooling"
    "org.opencontainers.image.version"     = "${version}"
  }

  contexts = {
    "${TAG_BASE}/knot-ubuntu:${UBUNTU_BASE_VERSION}" = "target:knot-ubuntu-${replace(UBUNTU_BASE_VERSION, ".", "-")}"
  }

  args = {
    IMAGE_BASE         = "ubuntu"
    IMAGE_VERSION      = "${UBUNTU_BASE_VERSION}"
    TAG_BASE           = "${TAG_BASE}"
    SCRIPTLING_VERSION = "v${version}"
  }

  tags = concat(
    version_tags("knot-scriptling", version),
    [
      "${TAG_BASE}/knot-scriptling:${major_minor(version)}",
      "${TAG_BASE}/knot-scriptling:latest",
    ],
  )

  cache-from = cache_from("knot-scriptling", "${version}")
  cache-to   = cache_to("knot-scriptling", "${version}")
}

target "knot-scriptling-alpine" {
  name        = "knot-scriptling-alpine-${replace(version, ".", "-")}"
  description = "Scriptling runtime image (Alpine)"
  matrix      = { version = SCRIPTLING_VERSIONS }
  inherits    = ["_common"]
  context     = "./scriptling"
  dockerfile  = "Dockerfile.alpine"

  labels = {
    "org.opencontainers.image.title"       = "Knot Scriptling"
    "org.opencontainers.image.description" = "Scriptling runtime image (Alpine) with knot startup tooling"
    "org.opencontainers.image.version"     = "${version}-alpine"
  }

  contexts = {
    "${TAG_BASE}/knot-alpine:${KNOT_ALPINE_BASE_VERSION}" = "target:knot-alpine-${replace(KNOT_ALPINE_BASE_VERSION, ".", "-")}"
  }

  args = {
    ALPINE_VERSION     = "${KNOT_ALPINE_BASE_VERSION}"
    TAG_BASE           = "${TAG_BASE}"
    SCRIPTLING_VERSION = "v${version}"
  }

  tags = concat(
    version_tags("knot-scriptling", "${version}-alpine"),
    [
      "${TAG_BASE}/knot-scriptling:${major_minor(version)}-alpine",
      "${TAG_BASE}/knot-scriptling:alpine",
    ],
  )

  cache-from = cache_from("knot-scriptling", "${version}-alpine")
  cache-to   = cache_to("knot-scriptling", "${version}-alpine")
}
