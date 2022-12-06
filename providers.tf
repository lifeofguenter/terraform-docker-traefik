terraform {
  required_version = ">= 1.3.0"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }

    time = {
      source = "hashicorp/time"
    }
  }
}
