resource "time_sleep" "grace" {
  depends_on       = [docker_container.main]
  destroy_duration = "${var.deregistration_delay}s"

  triggers = {
    container_name = docker_container.main.name
  }

  lifecycle {
    create_before_destroy = true
  }
}
