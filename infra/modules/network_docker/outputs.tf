output "network_name" {
  description = "Name of the Docker network"
  value       = docker_network.this.name
}
