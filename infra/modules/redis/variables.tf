variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "image" {
  description = "Docker image to be used for the PostgreSQL container"
  type        = string
  default     = "postgres:latest"
}

variable "network_name" {
  description = "Name of the Docker network to connect the container to"
  type        = string
  default     = ""
}

variable "database" {
  description = "Database name"
  type        = string
  default     = "mydb"
}

variable "username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Database password"
  type        = string
  default     = "password"
}

variable "port" {
  description = "Port on which Redis will listen"
  type        = number
  default     = 6379
}
