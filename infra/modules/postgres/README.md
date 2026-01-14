# postgres

This module manages a single Postgres database container.

It encapsulates the Docker-specific setup required to run Postgres and exposes
connection information for dependent services.

## Responsibility

- Run a Postgres container
- Initialize database name and credentials
- Expose connection details via outputs

## Inputs

- `name` – container name
- `network_name` – Docker network to attach to
- `db` – database name
- `user` – database user
- `password` – database password
- `image` – Postgres image (optional)

## Outputs

- `host`
- `port`
- `database`
- `username`

## Notes

This module does not manage schema, migrations, or backups.
It is intentionally limited to infrastructure concerns.

