# Architektur

## GitOps-Fluss

```mermaid
flowchart LR
  dev[Commit] --> forgejo[Forgejo<br/>homelab/kops]
  renovate[Renovate] -->|PR| forgejo
  forgejo -->|GitRepository| flux[Flux<br/>flux-operator]
  flux --> hcloud[Cluster hcloud]
  flux --> home[Cluster home]
```

Jeder Cluster hat eine eigene Flux-Instanz, die ihren Pfad `kubernetes/<cluster>/flux` synchronisiert.

## Doku-Pipeline

```mermaid
flowchart LR
  forgejo[Forgejo] --> runner[forgejo-runner]
  runner --> build[zensical build]
  build --> sync[aws s3 sync]
  sync -->|S3 :3900| garage[Garage<br/>garage-cluster]
  garage -->|Web :3902| gw[envoy-external]
  gw --> browser[Browser]
```

Warum diese Kombination: [ADR 0001](../decisions/0001-docs-zensical-garage.md).
