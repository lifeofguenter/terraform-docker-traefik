# Docker Traefik Terraform module

[![pre-commit](https://github.com/lifeofguenter/terraform-docker-traefik/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/lifeofguenter/terraform-docker-traefik/actions/workflows/pre-commit.yml)

Terraform module which deploys a [Docker service](https://doc.traefik.io/traefik/providers/docker/)
on [Traefik](https://traefik.io/traefik/) with zero downtime (red/black).

## Usage

```hcl
module "service" {
  source  = "lifeofguenter/traefik/docker"

  name          = "foobar-service"
  image         = "nginx"
  memory        = 256
  listener_rule = "Host(`foobar.mydomain.com`)"
  revision      = var.build_number

  service_network = docker_network.service.name
  traefik_network = "services"

  certresolver = "basic"

  http_entrypoints = ["web"]
  http_middlewares = ["https_redirect@file"]

  https_entrypoints = ["web_secure"]
  https_middlewares = ["compression@file"]

  environment = {
    VERSION = var.build_number
  }

  healthcheck = {
    command      = ["CMD-SHELL", "wget -q --spider --proxy=off localhost:3000/ || exit 1"]
    retries      = 3
    interval     = 20
    start_period = 60
    timeout      = 5
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_docker"></a> [docker](#provider\_docker) | 3.0.2 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.12.0 |

## Resources

| Name | Type |
|------|------|
| [docker_container.main](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container) | resource |
| [docker_image.main](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [time_sleep.grace](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [docker_registry_image.main](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/data-sources/registry_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_basic_auth_users"></a> [basic\_auth\_users](#input\_basic\_auth\_users) | List of authorized users. | `list(string)` | `[]` | no |
| <a name="input_cert_sans"></a> [cert\_sans](#input\_cert\_sans) | List of SANs for the cert. | `list(string)` | `[]` | no |
| <a name="input_certresolver"></a> [certresolver](#input\_certresolver) | Name of certificate resolver. | `string` | `null` | no |
| <a name="input_command"></a> [command](#input\_command) | The command to use to start the container. | `list(string)` | `[]` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Explicit container port to forward traffic to. | `number` | `null` | no |
| <a name="input_cpu_set"></a> [cpu\_set](#input\_cpu\_set) | A comma-separated list or hyphen-separated range of CPUs a container can use. | `string` | `null` | no |
| <a name="input_cpu_shares"></a> [cpu\_shares](#input\_cpu\_shares) | CPU shares (relative weight) for the container. | `number` | `null` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | Amount of seconds to wait for open connections to drain before stopping the container. | `number` | `60` | no |
| <a name="input_entrypoint"></a> [entrypoint](#input\_entrypoint) | The command to use as the Entrypoint for the container. | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment variables to pass to a container. | `map(string)` | `{}` | no |
| <a name="input_header_sts"></a> [header\_sts](#input\_header\_sts) | Add the Strict-Transport-Security header to the response. | <pre>object({<br/>    seconds            = optional(number, 0)<br/>    include_subdomains = optional(bool, false)<br/>    preload            = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_healthcheck"></a> [healthcheck](#input\_healthcheck) | The container health check command and associated configuration parameters for the container. | <pre>object({<br/>    command      = list(string)<br/>    interval     = optional(number, 30)<br/>    timeout      = optional(number, 30)<br/>    start_period = optional(number, 0)<br/>    retries      = optional(number, 3)<br/>  })</pre> | `null` | no |
| <a name="input_http_entrypoints"></a> [http\_entrypoints](#input\_http\_entrypoints) | List of HTTP entrypoints. | `list(string)` | `[]` | no |
| <a name="input_http_middlewares"></a> [http\_middlewares](#input\_http\_middlewares) | List of HTTP middlewares. | `list(string)` | `[]` | no |
| <a name="input_https_entrypoints"></a> [https\_entrypoints](#input\_https\_entrypoints) | List of HTTPS entrypoints. | `list(string)` | `[]` | no |
| <a name="input_https_middlewares"></a> [https\_middlewares](#input\_https\_middlewares) | List of HTTPS middlewares. | `list(string)` | `[]` | no |
| <a name="input_image"></a> [image](#input\_image) | The image used to start a container. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Additional lables to set. | `map(string)` | `{}` | no |
| <a name="input_listener_rule"></a> [listener\_rule](#input\_listener\_rule) | Sets the routing rule. | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount (in MiB) of memory to present to the container. | `number` | n/a | yes |
| <a name="input_mounts"></a> [mounts](#input\_mounts) | List for mounts to be added to containers created as part of the service. | <pre>list(object({<br/>    type      = string<br/>    target    = string<br/>    source    = optional(string, null)<br/>    read_only = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the service. | `string` | n/a | yes |
| <a name="input_publish"></a> [publish](#input\_publish) | List of ports to publish. | <pre>list(object({<br/>    internal = number<br/>    external = number<br/>    ip       = optional(string, null)<br/>    protocol = optional(string, "tcp")<br/>  }))</pre> | `[]` | no |
| <a name="input_revision"></a> [revision](#input\_revision) | Revision number of this service. | `number` | n/a | yes |
| <a name="input_service_network"></a> [service\_network](#input\_service\_network) | Name of the service docker network. | `string` | `null` | no |
| <a name="input_traefik_network"></a> [traefik\_network](#input\_traefik\_network) | Name of the Traefik docker network. | `string` | `null` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | List for mounting volumes in the container. | <pre>list(object({<br/>    container_path = optional(string, null)<br/>    from_container = optional(string, null)<br/>    host_path      = optional(string, null)<br/>    read_only      = optional(bool, false)<br/>    volume_name    = optional(string, null)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_docker_image_id"></a> [docker\_image\_id](#output\_docker\_image\_id) | The ID of the image. |
| <a name="output_docker_image_name"></a> [docker\_image\_name](#output\_docker\_image\_name) | The name of the Docker image. |
<!-- END_TF_DOCS -->

## Contribute

### Setup

#### Mac

```bash
$ brew install pre-commit terraform-docs
```

#### Linux

```bash
$ pip install --user pre-commit
$ ver="$(curl -sSLf https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | jq -r '.tag_name')"; \
  curl -sSLO \
  "https://terraform-docs.io/dl/${ver}/terraform-docs-${ver}-$(uname)-amd64.tar.gz" && \
  tar xf terraform-docs*.tar.gz && \
  chmod +x terraform-docs && \
  sudo mv terraform-docs /usr/local/bin/
```

### Pre-commit

Run once in this directory:

```bash
$ pre-commit install
```

Optionally you can trigger the hooks before committing:

```bash
$ pre-commit run -a
```
