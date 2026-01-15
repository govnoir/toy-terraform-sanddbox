# networking

This module manages a single Docker network.

It exists to provide an isolated, named network that other modules can attach to.
The module deliberately manages exactly one primary resource.

## Responsibility

- Create one Docker network
- Expose the network name as an output for consumers

## Inputs

- `name` – name of the Docker network

## Outputs

- `network_name` – name of the created network

## Notes

This module has no knowledge of services, containers, or environments.
All composition happens in the calling stack.
