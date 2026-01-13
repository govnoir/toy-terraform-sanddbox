# service

This module manages a single Docker container representing an application or worker.

It is intentionally generic and reusable. The module does not encode application
semantics and is used for all runtime services in the system.

## Responsibility

- Run one container from a given image
- Attach the container to a provided network
- Configure environment variables, ports, and labels

## Inputs

- `name` – container name
- `image` – container image reference
- `network_name` – Docker network to attach to
- `env` – environment variables passed to the container
- `ports` – optional port mappings
- `labels` – optional container labels (e.g. for Traefik)

## Outputs

- `container_name`
- `container_id`

## Notes

This module intentionally avoids provider configuration and application logic.
It serves as the base abstraction for apps, workers, and supporting services.
