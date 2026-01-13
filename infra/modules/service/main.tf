resource "docker_image" "this" {
  name = var.image
}

resource "docker_container" "this" {
  name  = var.name
  image = docker_image.this.image_id

  networks_advanced {
    name = var.network_name
  }

  env = [for k, v in var.env : "${k}=${v}"]

  dynamic "labels" {
    for_each = var.labels
    content {
      label = labels.key
      value = labels.value
    }
  }

  dynamic "ports" {
    for_each = var.ports
    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }
}
