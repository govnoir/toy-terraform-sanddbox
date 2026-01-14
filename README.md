# Toy Terraform Sandbox Platform

This repository contains a local-first example of structuring Terraform configurations for a small but realistic platform.
The focus is on **Infrastructure as Code design**, module boundaries, and environment composition rather than on the applications themselves.

The platform is initially provisioned locally using the Docker provider and is intentionally structured so it can later be adapted to run on AWS with minimal changes to the stack composition. (Docker is role-playing as AWS locally)

## Goals

The main goals of this project are:
* Practice Terraform module design and composition
* Learn how to wire module outputs into inputs cleanly
* Separate reusable infrastructure modules from environment-specific stacks
* Keep the infrastructure repeatable, inspectable, and easy to destroy
* Prepare for a future transition from local Docker to AWS

## Development setup

This project requires that you have installed 
* [Terraform](https://developer.hashicorp.com/terraform/install)
* [Docker](https://docs.docker.com/desktop/)

The project also uses pre-commit to enforce Terraform formatting and basic validation, for installation see: [https://github.com/antonbabenko/pre-commit-terraform?tab=readme-ov-file#how-to-install](https://github.com/antonbabenko/pre-commit-terraform?tab=readme-ov-file#how-to-install). 

I use theese pre-commit hooks in the project:

`terraform-docs`
`tflint`
`jq`

### Linting

Terraform code is linted using `tflint`.

`tflint` is executed automatically via pre-commit hooks.
Project-specific configuration lives in `.tflint.hcl`.

No manual setup is required beyond installing pre-commit.

## Structure

The repository is split into two main concerns:

* **Modules**: reusable building blocks that encapsulate one responsibility.
* **Stacks**: environment-specific compositions of those modules.

```text
infra/
  modules/
    networking/
    service/
    postgres/
    redis/
    reverse_proxy_traefik/
  stacks/
    dev/
```

>(TODO) Application code (used only to validate infrastructure wiring) lives outside the Terraform code under `apps/`.

## Features

1. `dev` is a fully local environment provisioned via the Docker provider.
   It runs entirely on a developer laptop and requires no cloud credentials. (Docker pretending to be AWS).

2. Infrastructure is (will be) expressed using small, focused Terraform modules
   (`networking`, `service`, `postgres`, `redis`, `reverse_proxy_traefik`),
   each managing exactly one primary resource.

3. The `service` module is generic and reusable.
   It supports environment variables, port mappings, and labels, and is used for apps, workers, and supporting services.

4. Module composition happens only in stacks.
   Modules never reference each other directly; all wiring is done via inputs and outputs in the stack layer.

5. Tooling is integrated early:

   * `terraform fmt` and `terraform validate`
   * `tflint`
   * `pre-commit` hooks

6. The structure is intentionally cloud-agnostic.
   The Docker-based `dev` stack is designed to be conceptually replaceable with an AWS-based `prod` stack later, without changing module boundaries.

## Environments

### dev (local, Docker)

* Uses the `kreuzwerker/docker` provider.
* Provisions:

  * an isolated Docker network
  * application and worker services (TODO)
  * supporting services such as Postgres and Redis
  * a reverse proxy (Traefik) for HTTP routing
* Intended for rapid iteration and learning.

### prod (future/ TODO, AWS)

A future `prod` stack may be added that:

* Uses AWS providers instead of Docker.
* Reuses the same conceptual modules (networking, service, database),
  but with AWS-specific implementations (VPC, ECS, RDS, ALB).
* Lives in its own Terraform stack and state.

A separate `stage` environment is intentionally omitted for now to keep the scope focused. The project prioritizes correctness and structure over completeness.

## Non-goals

* This is not a production-ready platform.
* The application code is intentionally minimal.
* Advanced AWS features (IAM policies, autoscaling, multi-region setups) are out of scope initially.

## Why this exists

This repository is meant to answer one question well:

> “How do I structure Terraform for a real system, even when starting small, according to best practise ?”

Everything in this project is optimized for clarity, composability, and learning transfer rather than feature depth.

## Resources used
These are my resources on Terraform, except for the [official documentation](https://developer.hashicorp.com/terraform/docs):

https://www.terraform-best-practices.com/

https://github.com/antonbabenko/terragrunt-reference-architecture

https://www.digitalocean.com/community/tutorials/how-to-structure-a-terraform-project

https://github.com/antonbabenko. <- Terraform Hero
