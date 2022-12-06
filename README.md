# Docker Traefik Terraform module

Terraform module which deploys a [Docker service](https://doc.traefik.io/traefik/providers/docker/)
on [Traefik](https://traefik.io/traefik/) with zero downtime (red/black).

## Usage

```hcl
module "vpc" {
  source = "lifeofguenter/traefik/docker"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_docker"></a> [docker](#provider\_docker) | 2.23.1 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.9.1 |

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
| <a name="input_certresolver"></a> [certresolver](#input\_certresolver) | Name of certificate resolver. | `string` | `null` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | Amount of seconds to wait for open connections to drain before stopping the container. | `number` | `60` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment variables to pass to a container. | `map(string)` | `{}` | no |
| <a name="input_healtcheck"></a> [healtcheck](#input\_healtcheck) | The container health check command and associated configuration parameters for the container. | <pre>object({<br>    command      = list(string)<br>    interval     = optional(number, 30)<br>    timeout      = optional(number, 30)<br>    start_period = optional(number, 0)<br>    retries      = optional(number, 3)<br>  })</pre> | n/a | yes |
| <a name="input_http_entrypoints"></a> [http\_entrypoints](#input\_http\_entrypoints) | List of HTTP entrypoints. | `list(string)` | `[]` | no |
| <a name="input_http_middlewares"></a> [http\_middlewares](#input\_http\_middlewares) | List of HTTP middlewares. | `list(string)` | `[]` | no |
| <a name="input_https_entrypoints"></a> [https\_entrypoints](#input\_https\_entrypoints) | List of HTTPS entrypoints. | `list(string)` | `[]` | no |
| <a name="input_https_middlewares"></a> [https\_middlewares](#input\_https\_middlewares) | List of HTTPS middlewares. | `list(string)` | `[]` | no |
| <a name="input_image"></a> [image](#input\_image) | The image used to start a container. | `string` | n/a | yes |
| <a name="input_listener_rule"></a> [listener\_rule](#input\_listener\_rule) | Sets the routing rule. | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount (in MiB) of memory to present to the container. | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the service. | `string` | n/a | yes |
| <a name="input_revision"></a> [revision](#input\_revision) | Revision number of this service. | `number` | n/a | yes |
| <a name="input_service_network"></a> [service\_network](#input\_service\_network) | Name of the service docker network. | `string` | `null` | no |
| <a name="input_traefik_network"></a> [traefik\_network](#input\_traefik\_network) | Name of the Traefik docker network. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

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
