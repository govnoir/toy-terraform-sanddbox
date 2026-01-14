# Worker

The worker is a simple background process that periodically writes a heartbeat
row into Postgres and optionally updates a Redis key.

It exists to generate observable side-effects for the landing app.

## Building the image

The worker Docker image is built locally and referenced by Terraform.

From the repository root:

```
docker build -t toy-worker:dev ./apps/worker
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
- `WORKER_ID` (defaults to a random UUID)
- `INTERVAL_SECONDS` (defaults to 5)

## Behavior

On each interval, the worker:
1. Ensures the `worker_heartbeat` table exists.
2. Inserts a new heartbeat row.
3. Updates a Redis `last_seen` key if Redis is configured.

## Notes

This process has no HTTP interface and is not exposed via Traefik.
