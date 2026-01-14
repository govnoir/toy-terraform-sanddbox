output "host" {
  description = "Hostname to use from other containers on the same Docker network."
  value       = docker_container.postgres.name
}

output "port" {
  description = "The port on which PostgreSQL is listening"
  value       = var.port
}

output "database" {
  description = "The name of the PostgreSQL database"
  value       = var.database
}

output "username" {
  description = "The username for the PostgreSQL database"
  value       = var.username
}
