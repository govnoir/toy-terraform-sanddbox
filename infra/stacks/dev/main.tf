module "network" {
  source = "../../modules/network"
  name   = local.network
}

module "hello" {
  source       = "../../modules/service"
  name         = "${var.env}-hello"
  image        = "hashicorp/http-echo:1.0"
  network_name = module.network.network_name
  labels = {
    env     = var.env
    example = "true"
  }

  env = {
    ECHO_TEXT = "hello from terraform"
  }

  ports = [{
    internal = 5678
    external = 18080
  }]
}
