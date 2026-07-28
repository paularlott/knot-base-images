# =============================================================================
# Variables (overridable via environment variables; see Makefile for defaults)
# =============================================================================

variable "TAG_BASE" {
  default = "paularlott"
}

variable "CACHE_TAG_BASE" {
  default = ""
}

variable "DOCKER_HUB" {
  default = ""
}

variable "APT_CACHE" {
  default = ""
}

variable "BUILD_DATE" {
  default = ""
}

variable "UBUNTU_VERSIONS" {
  type    = list(string)
  default = ["24.04"]
}

variable "PHP_UBUNTU_BASE_VERSION" {
  default = "24.04"
}

variable "PHP_VERSIONS" {
  type    = list(string)
  default = ["8.5"]
}

variable "CADDY_VERSION" {
  default = "2.11.4"
}

variable "MARIADB_VERSIONS" {
  type    = list(string)
  default = ["12.3"]
}

variable "VALKEY_VERSIONS" {
  type    = list(string)
  default = ["9.1.1"]
}

variable "GOSU_VERSION" {
  default = "1.19"
}

# =============================================================================
# Helper functions and shared target
# =============================================================================

function "cache_base" {
  params = []
  result = CACHE_TAG_BASE == "" ? TAG_BASE : CACHE_TAG_BASE
}

function "major_minor" {
  params = [version]
  result = "${split(".", version)[0]}.${split(".", version)[1]}"
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
    "knot-ubuntu",
    "knot-caddy",
    "knot-ubuntu-php",
    "knot-ubuntu-desktop",
    "knot-valkey",
    "knot-mariadb",
  ]
}

# =============================================================================
# Targets
# =============================================================================

target "knot-ubuntu" {
  name        = "knot-ubuntu-${replace(version, ".", "-")}"
  description = "Base Ubuntu image with code-server and startup scripts"
  matrix      = { version = UBUNTU_VERSIONS }
  inherits    = ["_common"]
  context     = "./base"

  labels = {
    "org.opencontainers.image.title"       = "Knot Ubuntu"
    "org.opencontainers.image.description" = "Base Ubuntu image with knot startup scripts"
    "org.opencontainers.image.version"     = "${version}"
  }

  args = {
    IMAGE_BASE    = "ubuntu"
    IMAGE_VERSION = "${version}"
    DOCKER_HUB    = "${DOCKER_HUB}"
    APT_CACHE     = "${APT_CACHE}"
    GOSU_VERSION  = "${GOSU_VERSION}"
  }

  tags = [
    "${TAG_BASE}/knot-ubuntu:${version}",
    "${TAG_BASE}/knot-ubuntu:${version}-${BUILD_DATE}",
  ]

  cache-from = [{
    type = "registry"
    ref  = "${cache_base()}/knot-ubuntu:buildcache-${version}"
  }]
  cache-to = [{
    type              = "registry"
    ref               = "${cache_base()}/knot-ubuntu:buildcache-${version}"
    mode              = "max"
    "oci-media-types" = true
    "image-manifest"  = true
  }]
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
    IMAGE_VERSION = "${CADDY_VERSION}"
    DOCKER_HUB    = "${DOCKER_HUB}"
  }

  tags = [
    "${TAG_BASE}/knot-caddy:${CADDY_VERSION}",
    "${TAG_BASE}/knot-caddy:${CADDY_VERSION}-${BUILD_DATE}",
  ]

  cache-from = [{
    type = "registry"
    ref  = "${cache_base()}/knot-caddy:buildcache-${CADDY_VERSION}"
  }]
  cache-to = [{
    type              = "registry"
    ref               = "${cache_base()}/knot-caddy:buildcache-${CADDY_VERSION}"
    mode              = "max"
    "oci-media-types" = true
    "image-manifest"  = true
  }]
}

target "knot-ubuntu-desktop" {
  name        = "knot-ubuntu-desktop-${replace(version, ".", "-")}"
  description = "Ubuntu desktop image with XFCE and code-server"
  matrix      = { version = UBUNTU_VERSIONS }
  inherits    = ["_common"]
  context     = "./desktop"

  labels = {
    "org.opencontainers.image.title"       = "Knot Desktop"
    "org.opencontainers.image.description" = "Ubuntu desktop image with XFCE and code-server"
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

  tags = [
    "${TAG_BASE}/knot-desktop:${version}",
    "${TAG_BASE}/knot-desktop:${version}-${BUILD_DATE}",
  ]

  cache-from = [{
    type = "registry"
    ref  = "${cache_base()}/knot-desktop:buildcache-${version}"
  }]
  cache-to = [{
    type              = "registry"
    ref               = "${cache_base()}/knot-desktop:buildcache-${version}"
    mode              = "max"
    "oci-media-types" = true
    "image-manifest"  = true
  }]
}

target "knot-ubuntu-php" {
  name        = "knot-ubuntu-php-${replace(ubuntu, ".", "-")}-${replace(php, ".", "-")}"
  description = "Ubuntu + Caddy + PHP image"
  matrix      = {
    ubuntu = UBUNTU_VERSIONS
    php    = PHP_VERSIONS
  }
  inherits    = ["_common"]
  context     = "./php"

  labels = {
    "org.opencontainers.image.title"       = "Knot PHP"
    "org.opencontainers.image.description" = "Ubuntu + Caddy + PHP image"
    "org.opencontainers.image.version"     = "${ubuntu}-${php}"
  }

  contexts = {
    "${TAG_BASE}/knot-caddy:${CADDY_VERSION}" = "target:knot-caddy"
    "${TAG_BASE}/knot-ubuntu:${ubuntu}"        = "target:knot-ubuntu-${replace(ubuntu, ".", "-")}"
  }

  args = {
    IMAGE_BASE    = "ubuntu"
    IMAGE_VERSION = "${ubuntu}"
    DOCKER_HUB    = "${DOCKER_HUB}"
    APT_CACHE     = "${APT_CACHE}"
    TAG_BASE      = "${TAG_BASE}"
    CADDY_VERSION = "${CADDY_VERSION}"
    PHP_VERSION   = "${php}"
  }

  tags = concat(
    [
      "${TAG_BASE}/knot-php:${ubuntu}-${php}",
      "${TAG_BASE}/knot-php:${ubuntu}-${php}-${BUILD_DATE}",
    ],
    ubuntu == PHP_UBUNTU_BASE_VERSION ? [
      "${TAG_BASE}/knot-php:${php}",
      "${TAG_BASE}/knot-php:${php}-${BUILD_DATE}",
    ] : []
  )

  cache-from = [{
    type = "registry"
    ref  = "${cache_base()}/knot-php:buildcache-${ubuntu}-${php}"
  }]
  cache-to = [{
    type              = "registry"
    ref               = "${cache_base()}/knot-php:buildcache-${ubuntu}-${php}"
    mode              = "max"
    "oci-media-types" = true
    "image-manifest"  = true
  }]
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
    GOSU_VERSION    = "${GOSU_VERSION}"
  }

  tags = [
    "${TAG_BASE}/knot-mariadb:${version}",
    "${TAG_BASE}/knot-mariadb:${version}-${BUILD_DATE}",
  ]

  cache-from = [{
    type = "registry"
    ref  = "${cache_base()}/knot-mariadb:buildcache-${version}"
  }]
  cache-to = [{
    type              = "registry"
    ref               = "${cache_base()}/knot-mariadb:buildcache-${version}"
    mode              = "max"
    "oci-media-types" = true
    "image-manifest"  = true
  }]
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
    GOSU_VERSION   = "${GOSU_VERSION}"
  }

  tags = [
    "${TAG_BASE}/knot-valkey:${version}",
    "${TAG_BASE}/knot-valkey:${version}-${BUILD_DATE}",
    "${TAG_BASE}/knot-valkey:${major_minor(version)}",
  ]

  cache-from = [{
    type = "registry"
    ref  = "${cache_base()}/knot-valkey:buildcache-${version}"
  }]
  cache-to = [{
    type              = "registry"
    ref               = "${cache_base()}/knot-valkey:buildcache-${version}"
    mode              = "max"
    "oci-media-types" = true
    "image-manifest"  = true
  }]
}
