---
title: bootstrap
description: Setting up the home cluster from scratch.
---

# bootstrap

How the `home` cluster is created from an empty machine to a Flux-managed Kubernetes: infrastructure provisioning, Talos, and the Flux bootstrap. The authoritative files live under [kubernetes/bootstrap](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/bootstrap).

## Phases

Bootstrap is split into numbered phases, executed in order:

| Phase | Purpose |
| --- | --- |
| [01_tofu](01_tofu.md) | Provision the server infrastructure with OpenTofu (only when a cloud server is needed - the `home` node is local hardware) |
| [02_talos](02_talos.md) | Install and configure Talos Linux with topf |
| [03_flux](03_flux.md) | Install CRDs and the initial apps, hand over to GitOps |

## Encryption

Secrets are SOPS-encrypted with age keys and decrypted in-cluster by Flux - see [encryption](encryption/index.md): [sops-age usage](encryption/sops-age.md) and [key rotation](encryption/key-rotation.md).
