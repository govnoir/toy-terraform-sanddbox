resource "docker_image" "redis" {
  name = var.image
}

resource "docker_container" "redis" {
  name  = var.name
  image = docker_image.redis.image_id

  networks_advanced {
    name = var.network_name
  }

  env = [
    "REDIS_USER=${var.username}",
    "REDIS_PASSWORD=${var.password}",
    "REDIS_DB=${var.database}"
  ]

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U ${var.username}"]
    interval = "30s"
    timeout  = "10s"
    retries  = 5
  }
}
