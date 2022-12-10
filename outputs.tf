output "docker_image_name" {
  description = "The name of the Docker image."
  value       = docker_image.main.name
}

output "docker_image_id" {
  description = "The ID of the image."
  value       = docker_image.main.image_id
}
