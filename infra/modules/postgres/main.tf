resource "docker_image" "postgres" {
  name = var.image
}

resource "docker_container" "postgres" {
  name  = var.name
  image = docker_image.postgres.image_id

  networks_advanced {
    name = var.network_name
  }

  dynamic "labels" {
    for_each = var.labels
    content {
      label = labels.key
      value = labels.value
    }
  }

  env = [
    "POSTGRES_USER=${var.username}",
    "POSTGRES_PASSWORD=${var.password}",
    "POSTGRES_DB=${var.database}"
  ]

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U ${var.username}"]
    interval = "30s"
    timeout  = "10s"
    retries  = 5
  }
}
