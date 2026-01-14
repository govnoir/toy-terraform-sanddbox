module "network" {
  source = "../../modules/network"
  name   = local.network
}

module "traefik" {
  source       = "../../modules/reverse_proxy_traefik"
  name         = "${var.env}-traefik"
  network_name = module.network.network_name
}

module "postgres" {
  source       = "../../modules/postgres"
  name         = "${var.env}-postgres"
  image        = "postgres:latest"
  network_name = module.network.network_name
  database     = "postgres"
  username     = "postgres"
  password     = "postgres"

  labels = {
    "traefik.enable" = "true"
  }
}

module "redis" {
  source       = "../../modules/redis"
  name         = "${var.env}-redis"
  image        = "redis:latest"
  network_name = module.network.network_name
  database     = "redis"
  username     = "redis"
  password     = "redis"

  labels = {
    "traefik.enable" = "true"
  }
}

module "landing" {
  source       = "../../modules/service"
  name         = "${var.env}-landing"
  image        = "toy-landing:dev"
  network_name = module.network.network_name

  labels = {
    env     = var.env
    example = "true"

    "traefik.enable"                                         = "true"
    "traefik.http.routers.landing.rule"                      = "PathPrefix(`/`)"
    "traefik.http.routers.landing.entrypoints"               = "web"
    "traefik.http.services.landing.loadbalancer.server.port" = "8080"
  }

  env = {
    POSTGRES_HOST = module.postgres.host
    POSTGRES_DB   = module.postgres.database
    POSTGRES_USER = module.postgres.username
    POSTGRES_PASS = "postgres"

    REDIS_HOST = module.redis.host
    REDIS_USER = module.redis.username
    REDIS_DB   = "redis"
  }
}

module "worker" {
  source       = "../../modules/service"
  name         = "${var.env}-worker"
  image        = "toy-worker:dev"
  network_name = module.network.network_name

  env = {
    POSTGRES_HOST = module.postgres.host
    POSTGRES_DB   = module.postgres.database
    POSTGRES_USER = module.postgres.username
    POSTGRES_PASS = "postgres"

    REDIS_HOST = module.redis.host
    REDIS_USER = module.redis.username
    REDIS_DB   = "redis"
  }
}

module "hello" {
  source       = "../../modules/service"
  name         = "${var.env}-hello"
  image        = "hashicorp/http-echo:1.0"
  network_name = module.network.network_name

  labels = {
    env     = var.env
    example = "true"

    "traefik.enable"                                       = "true"
    "traefik.http.routers.hello.rule"                      = "PathPrefix(`/hello`)"
    "traefik.http.routers.hello.entrypoints"               = "web"
    "traefik.http.services.hello.loadbalancer.server.port" = "5678"
  }

  env = {
    ECHO_TEXT = "hello from terraform - via traefik"
  }

  #   ports = []
}
