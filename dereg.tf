resource "time_sleep" "grace" {
  depends_on       = [docker_container.main]
  destroy_duration = "${var.deregistration_delay}s"
}
