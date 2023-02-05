variable "name" {
  description = "The name of the service."
  type        = string
}

variable "image" {
  description = "The image used to start a container."
  type        = string
}

variable "revision" {
  description = "Revision number of this service."
  type        = number
}

variable "memory" {
  description = "The amount (in MiB) of memory to present to the container."
  type        = number
}

variable "environment" {
  description = "The environment variables to pass to a container."
  type        = map(string)
  default     = {}
}

variable "service_network" {
  description = "Name of the service docker network."
  type        = string
  default     = null
}

variable "traefik_network" {
  description = "Name of the Traefik docker network."
  type        = string
  default     = null
}

variable "http_entrypoints" {
  description = "List of HTTP entrypoints."
  type        = list(string)
  default     = []
}

variable "https_entrypoints" {
  description = "List of HTTPS entrypoints."
  type        = list(string)
  default     = []
}

variable "http_middlewares" {
  description = "List of HTTP middlewares."
  type        = list(string)
  default     = []
}

variable "https_middlewares" {
  description = "List of HTTPS middlewares."
  type        = list(string)
  default     = []
}

variable "certresolver" {
  description = "Name of certificate resolver."
  type        = string
  default     = null
}

variable "cert_sans" {
  description = "List of SANs for the cert."
  type        = list(string)
  default     = []
}

variable "listener_rule" {
  description = "Sets the routing rule."
  type        = string
}

variable "deregistration_delay" {
  description = "Amount of seconds to wait for open connections to drain before stopping the container."
  type        = number
  default     = 60
}

variable "healthcheck" {
  description = "The container health check command and associated configuration parameters for the container."
  type = object({
    command      = list(string)
    interval     = optional(number, 30)
    timeout      = optional(number, 30)
    start_period = optional(number, 0)
    retries      = optional(number, 3)
  })
}

variable "volumes" {
  description = "List for mounting volumes in the container."
  type = list(object({
    container_path = optional(string, null)
    from_container = optional(string, null)
    host_path      = optional(string, null)
    read_only      = optional(bool, false)
    volume_name    = optional(string, null)
  }))
  default = []
}

variable "mounts" {
  description = "List for mounts to be added to containers created as part of the service."
  type = list(object({
    type      = string
    target    = string
    source    = optional(string, null)
    read_only = optional(bool, false)
  }))
  default = []
}

variable "labels" {
  description = "Additional lables to set."
  type        = map(string)
  default     = {}
}

variable "command" {
  description = "The command to use to start the container."
  type        = list(string)
  default     = []
}

variable "entrypoint" {
  description = "The command to use as the Entrypoint for the container."
  type        = list(string)
  default     = []
}

variable "cpu_set" {
  description = "A comma-separated list or hyphen-separated range of CPUs a container can use."
  type        = string
  default     = null
}

variable "cpu_shares" {
  description = "CPU shares (relative weight) for the container."
  type        = number
  default     = null
}
