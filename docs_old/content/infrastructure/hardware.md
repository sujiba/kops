---
title: hardware
description: Physical machines and cloud dependencies of the kops homelab.
---

# hardware

The machines the clusters run on and the paid cloud services they depend on.

## Machines

| Device | Num | OS Disk | Data Disks | RAM | OS | Function |
| --- | --- | --- | --- | --- | --- | --- |
| ASUS NUC 15 Pro CU 5 225H | 1 | 2TB SSD | - | 96GB | Talos | Kubernetes (`home` cluster, single node) |
| Synology RS1221+ | 1 | - | 7x12TB btrfs (SHR-2) | 4GB | DSM | NFS storage (`${STORAGE_IP}`) |

The NUC's integrated Intel GPU (Core Ultra 5 225H, Arrow Lake-H) is exposed to workloads via the Intel GPU resource driver (DRA) and used by Jellyfin for hardware transcoding.

The `hcloud` cluster is a single Talos node on a Hetzner Cloud server, provisioned with OpenTofu (see [Bootstrap](../bootstrap/index.md)).

## Cloud dependencies

| Service | Use | Cost |
| --- | --- | --- |
| Netcup | DNS | ~80 EUR/yr |
| Hetzner | Server / Backup (object storage for kopiur) | ~25 EUR/mo |
