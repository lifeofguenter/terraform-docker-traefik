locals {
  router_name       = replace(var.name, "-", "_")
  router_name_http  = format("%s_http_%s", local.router_name, var.revision)
  router_name_https = format("%s_https_%s", local.router_name, var.revision)
}

resource "docker_container" "main" {
  name  = "${var.name}-${var.revision}"
  image = docker_image.main.name

  memory  = var.memory
  restart = "always"

  env = [for k, v in var.environment : "${k}=${v}"]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  ### Cert resolver
  dynamic "labels" {
    for_each = var.certresolver != null ? [1] : [0]
    content {
      label = "traefik.http.routers.${local.router_name_https}.tls.certresolver"
      value = var.certresolver
    }
  }

  ### Entrypoints
  dynamic "labels" {
    for_each = length(var.http_entrypoints) > 0 ? [1] : [0]
    content {
      label = "traefik.http.routers.${local.router_name_http}.entryPoints"
      value = join(",", var.http_entrypoints)
    }
  }

  dynamic "labels" {
    for_each = length(var.https_entrypoints) > 0 ? [1] : [0]
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
    for_each = length(var.http_middlewares) > 0 ? [1] : [0]
    content {
      label = "traefik.http.routers.${local.router_name_http}.middlewares"
      value = join(",", var.http_middlewares)
    }
  }

  dynamic "labels" {
    for_each = length(var.https_middlewares) > 0 ? [1] : [0]
    content {
      label = "traefik.http.routers.${local.router_name_https}.middlewares"
      value = join(",", var.https_middlewares)
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

  dynamic "labels" {
    for_each = var.traefik_network != null ? [1] : []
    content {
      label = "traefik.docker.network"
      value = var.traefik_network
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

  healthcheck {
    test         = var.healthcheck.command
    retries      = var.healthcheck.retries
    interval     = "${var.healthcheck.interval}s"
    start_period = "${var.healthcheck.start_period}s"
    timeout      = "${var.healthcheck.timeout}s"
  }

  destroy_grace_seconds = 60
  wait                  = true
  wait_timeout          = 120

  lifecycle {
    create_before_destroy = true
  }
}
