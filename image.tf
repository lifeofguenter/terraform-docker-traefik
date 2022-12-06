data "docker_registry_image" "main" {
  name = var.image
}

resource "docker_image" "main" {
  name          = data.docker_registry_image.main.name
  pull_triggers = [data.docker_registry_image.main.sha256_digest]
  keep_locally  = true

  lifecycle {
    create_before_destroy = true
  }
}
