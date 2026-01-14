# reverse_proxy_traefik

This module manages a Traefik reverse proxy container.

It provides HTTP routing for services running on the same Docker network
using container labels.

## Responsibility

- Run a Traefik container
- Expose HTTP entrypoints to the host
- Enable Docker-based service discovery

## Inputs

- `name` – container name
- `network_name` – Docker network to attach to

## Outputs

- `http_base_url` – base URL for accessing routed services

## Notes

This module mounts the Docker socket and is intended for local use only.
In a cloud environment, this role would be replaced by a managed load balancer.
