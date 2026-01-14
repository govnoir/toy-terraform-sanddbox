output "host" {
  description = "Hostname to use from other containers on the same Docker network."
  value       = docker_container.redis.name
}

output "port" {
  description = "The port on which Redis is listening"
  value       = var.port
}
