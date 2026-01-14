variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "network_name" {
  description = "Name of the Docker network to connect the container to"
  type        = string
}
