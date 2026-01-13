variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "image" {
  description = "Docker image to be used for the container"
  type        = string
  default     = ""
}

variable "network_name" {
  description = "Name of the Docker network to connect the container to"
  type        = string
  default     = ""
}

variable "env" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels to apply to the container"
  type        = map(string)
  default     = {}
}

variable "ports" {
  description = "List of port mappings for the container"
  type = list(object({
    internal = number
    external = number
  }))
  default = []
}