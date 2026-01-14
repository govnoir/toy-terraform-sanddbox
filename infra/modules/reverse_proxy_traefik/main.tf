resource "docker_image" "traefik" {
  name = "traefik:v3.0"
}

resource "docker_container" "traefik" {
  name  = var.name
  image = docker_image.traefik.image_id

  networks_advanced { name = var.network_name }

  ports {
    internal = 80
    external = 8080 # host port for http
  }

  ports {
    internal = 8080
    external = 8081 # host port for traefik dashboard
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  command = [
    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",
    "--entrypoints.web.address=:80",
    "--api.dashboard=true",
    "--api.insecure=true"
  ]
}
