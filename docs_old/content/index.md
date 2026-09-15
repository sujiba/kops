---
title: kops
description: Documentation for the kops homelab Kubernetes clusters.
---

# kops

Documentation for the kops homelab: two single-node Talos Kubernetes clusters (`home` on local hardware, `hcloud` on Hetzner Cloud) managed with FluxCD, Renovate and Forgejo Actions. The manifests live in the [kops repository](https://code.offene.cloud/homelab/kops); these pages explain what they do and why.

## Sections

| Section | Content |
| --- | --- |
| [infrastructure](infrastructure/index.md) | Network, hardware and storage |
| [bootstrap](bootstrap/index.md) | Setting up a cluster from scratch: OpenTofu, Talos, Flux, SOPS |
| [apps](apps/index.md) | Per-app documentation, grouped into platform, observability and services |

## Clusters

| Cluster | Where | Purpose |
| --- | --- | --- |
| `home` | ASUS NUC 15 Pro at home | Media, home automation, private self-hosted services |
| `hcloud` | Hetzner Cloud | Publicly reachable self-hosted services |

Both clusters are reconciled by Flux from this repository: `kubernetes/<cluster>/flux/cluster.yaml` points at `kubernetes/<cluster>/apps`, with SOPS decryption enabled cluster-wide. Secrets are SOPS-encrypted with age; cluster-wide values such as domains are substituted from the `cluster-secrets` Secret (e.g. `${EXTERNAL_DOMAIN}`, `${INTERNAL_DOMAIN}`).
