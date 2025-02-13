locals {
  router_name       = replace(var.name, "-", "_")
  router_name_http  = format("%s_http_%s", local.router_name, var.revision)
  router_name_https = format("%s_https_%s", local.router_name, var.revision)

  enable_tls = var.certresolver == null && length(var.https_entrypoints) > 0 ? true : false

  sans_main = length(var.cert_sans) > 0 ? var.cert_sans[0] : ""
  sans_alts = length(var.cert_sans) > 1 ? join(",", slice(var.cert_sans, 1, length(var.cert_sans))) : ""

  basicauth_name       = format("%s_basicauth_%s", local.router_name, var.revision)
  middleware_basicauth = length(var.basic_auth_users) > 0 ? "${local.basicauth_name}@docker" : ""

  middleware_sts = var.header_sts != null ? "sts@docker" : ""

  http_middlewares  = compact(concat(var.http_middlewares, [local.middleware_basicauth], [local.middleware_sts]))
  https_middlewares = compact(concat(var.https_middlewares, [local.middleware_basicauth], [local.middleware_sts]))
}

resource "docker_container" "main" {
  name  = "${var.name}-${var.revision}"
  image = docker_image.main.name

  cpu_set    = var.cpu_set
  cpu_shares = var.cpu_shares
  memory     = var.memory
  restart    = "always"

  env = [for k, v in var.environment : "${k}=${v}"]

  entrypoint = var.entrypoint
  command    = var.command

  labels {
    label = "traefik.enable"
    value = "true"
  }

  ### custom tls cert
  dynamic "labels" {
    for_each = local.enable_tls ? [1] : []
    content {
      label = "traefik.http.routers.${local.router_name_https}.tls"
      value = "true"
    }
  }

  ### Cert resolver
  dynamic "labels" {
    for_each = var.certresolver != null ? [1] : []
    content {
      label = "traefik.http.routers.${local.router_name_https}.tls.certresolver"
      value = var.certresolver
    }
  }

  ### Cert SANs
  dynamic "labels" {
    for_each = length(var.cert_sans) > 0 ? [1] : []
    content {
      label = "traefik.http.routers.${local.router_name_https}.tls.domains[0].main"
      value = local.sans_main
    }
  }

  dynamic "labels" {
    for_each = length(var.cert_sans) > 1 ? [1] : []
    content {
      label = "traefik.http.routers.${local.router_name_https}.tls.domains[0].sans"
      value = local.sans_alts
    }
  }

  ### Entrypoints
  dynamic "labels" {
    for_each = length(var.http_entrypoints) > 0 ? [1] : []
    content {
      label = "traefik.http.routers.${local.router_name_http}.entryPoints"
      value = join(",", var.http_entrypoints)
    }
  }

  dynamic "labels" {
    for_each = length(var.https_entrypoints) > 0 ? [1] : []
    content {
      label = "traefik.http.routers.${local.router_name_https}.entryPoints"
      value = join(",", var.https_entrypoints)
    }
  }

  ### Listener Rule
  labels {
    label = "traefik.http.routers.${local.router_name_http}.rule"
    value = var.listener_rule
  }

  labels {
    label = "traefik.http.routers.${local.router_name_https}.rule"
    value = var.listener_rule
  }

  ### Middlewares
  dynamic "labels" {
    for_each = length(var.http_middlewares) > 0 ? [1] : []
    content {
      label = "traefik.http.routers.${local.router_name_http}.middlewares"
      value = join(",", local.http_middlewares)
    }
  }

  dynamic "labels" {
    for_each = length(var.https_middlewares) > 0 ? [1] : []
    content {
      label = "traefik.http.routers.${local.router_name_https}.middlewares"
      value = join(",", local.https_middlewares)
    }
  }

  ### Network ###
  dynamic "networks_advanced" {
    for_each = var.service_network != null ? [1] : []
    content {
      name = var.service_network
    }
  }

  dynamic "networks_advanced" {
    for_each = var.traefik_network != null ? [1] : []
    content {
      name = var.traefik_network
    }
  }

  dynamic "networks_advanced" {
    for_each = var.networks
    content {
      name = networks_advanced.value
    }
  }

  dynamic "labels" {
    for_each = var.traefik_network != null ? [1] : []
    content {
      label = "traefik.docker.network"
      value = var.traefik_network
    }
  }

  ### Container port ###
  dynamic "labels" {
    for_each = var.container_port != null ? [1] : []
    content {
      label = "traefik.http.routers.${local.router_name_http}.service"
      value = local.router_name_http
    }
  }

  dynamic "labels" {
    for_each = var.container_port != null ? [1] : []
    content {
      label = "traefik.http.services.${local.router_name_http}.loadbalancer.server.port"
      value = tostring(var.container_port)
    }
  }

  dynamic "labels" {
    for_each = var.container_port != null ? [1] : []
    content {
      label = "traefik.http.routers.${local.router_name_https}.service"
      value = local.router_name_https
    }
  }

  dynamic "labels" {
    for_each = var.container_port != null ? [1] : []
    content {
      label = "traefik.http.services.${local.router_name_https}.loadbalancer.server.port"
      value = tostring(var.container_port)
    }
  }

  dynamic "labels" {
    for_each = length(var.basic_auth_users) > 0 ? [1] : []
    content {
      label = "traefik.http.middlewares.${local.basicauth_name}.basicauth.users"
      value = join(",", var.basic_auth_users)
    }
  }

  ### Headers: sts ###
  dynamic "labels" {
    for_each = var.header_sts != null ? [1] : []
    content {
      label = "traefik.http.middlewares.sts.headers.stsSeconds"
      value = var.header_sts.seconds
    }
  }

  dynamic "labels" {
    for_each = var.header_sts != null ? [1] : []
    content {
      label = "traefik.http.middlewares.sts.headers.stsIncludeSubdomains"
      value = var.header_sts.include_subdomains
    }
  }

  dynamic "labels" {
    for_each = var.header_sts != null ? [1] : []
    content {
      label = "traefik.http.middlewares.sts.headers.stsPreload"
      value = var.header_sts.preload
    }
  }

  ### Additional labels ###
  dynamic "labels" {
    for_each = var.labels
    content {
      label = labels.key
      value = labels.value
    }
  }

  ### Volumes ###
  dynamic "volumes" {
    for_each = var.volumes
    content {
      container_path = volumes.value["container_path"]
      from_container = volumes.value["from_container"]
      host_path      = volumes.value["host_path"]
      read_only      = volumes.value["read_only"]
      volume_name    = volumes.value["volume_name"]
    }
  }

  ### Mounts ###
  dynamic "mounts" {
    for_each = var.mounts
    content {
      type      = mounts.value["type"]
      target    = mounts.value["target"]
      source    = mounts.value["source"]
      read_only = mounts.value["read_only"]
    }
  }

  ### Publish ###
  dynamic "ports" {
    for_each = var.publish
    content {
      internal = ports.value["internal"]
      external = ports.value["external"]
      ip       = ports.value["ip"]
      protocol = ports.value["protocol"]
    }
  }

  ### Red/black ###
  labels {
    label = "traefik.http.routers.${local.router_name_http}.priority"
    value = var.revision
  }

  labels {
    label = "traefik.http.routers.${local.router_name_https}.priority"
    value = var.revision
  }

  dynamic "healthcheck" {
    for_each = var.healthcheck != null ? [1] : []
    content {
      test         = var.healthcheck.command
      retries      = var.healthcheck.retries
      interval     = "${var.healthcheck.interval}s"
      start_period = "${var.healthcheck.start_period}s"
      timeout      = "${var.healthcheck.timeout}s"
    }
  }

  destroy_grace_seconds = 60
  wait                  = true
  wait_timeout          = 120

  lifecycle {
    create_before_destroy = true
  }
}
