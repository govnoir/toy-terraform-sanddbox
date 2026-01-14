# redis

This module manages a single Redis container.

It provides a minimal Redis instance intended for local development and
infrastructure wiring exercises.

## Responsibility

- Run one Redis container
- Attach it to a shared network
- Expose connection details

## Inputs

- `name` – container name
- `network_name` – Docker network to attach to
- `image` – Redis image (optional)

## Outputs

- `host`
- `port`

## Notes

Persistence and high availability are intentionally out of scope.
The module exists to model a dependency, not production Redis behavior.
