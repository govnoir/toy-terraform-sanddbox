# Landing app

The landing app is a small FastAPI service used to validate Terraform-provisioned
infrastructure wiring.

It displays live connectivity checks to Postgres and Redis and shows the most
recent worker heartbeat written to the database.

## Building the image

The landing app Docker image is built locally and referenced by Terraform.

From the repository root:

```
docker build -t toy-landing:dev ./apps/landing
```

## Environment variables

Required:

- `POSTGRES_HOST`
- `POSTGRES_PORT`
- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASS`

Optional:

- `REDIS_HOST`
- `REDIS_PORT`
- `ENV` (defaults to `dev`)

## Endpoints

- `/` – HTML status page
- `/healthz` – basic liveness endpoint

## Notes

This application is not intended for production use.
It exists solely to make infrastructure state observable.
