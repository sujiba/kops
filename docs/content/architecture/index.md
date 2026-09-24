---
icon: lucide/network
---

# Architecture

## GitOps flow

```mermaid
flowchart LR
  dev[Commit] --> forgejo[Forgejo<br/>homelab/kops]
  renovate[Renovate] -->|PR| forgejo
  forgejo -->|GitRepository| flux[Flux<br/>flux-operator]
  flux --> hcloud[Cluster hcloud]
  flux --> home[Cluster home]
```

Each cluster has its own Flux instance that syncs its path `kubernetes/<cluster>/flux`.

## Docs pipeline

```mermaid
flowchart LR
  forgejo[Forgejo] --> runner[forgejo-runner]
  runner --> build[zensical build]
  build --> sync[aws s3 sync]
  sync -->|S3 :3900| garage[Garage<br/>garage-cluster]
  garage -->|Web :3902| gw[envoy-external]
  gw --> browser[Browser]
```

Why this combination: [ADR 0001](../decisions/0001-docs-zensical-garage.md).
