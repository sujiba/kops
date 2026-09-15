---
title: storage
description: Storage classes, NFS and backups in the kops clusters.
---

# storage

Where cluster data lives: local storage classes, the NAS via NFS, and off-site backups.

## Storage classes

| Class | Cluster | Backing |
| --- | --- | --- |
| `openebs-hostpath` | `hcloud` | OpenEBS local hostpath on the node disk (`storage` namespace) |
| `miroir-local` | `home` | Local storage managed by miroir (`miroir-system` namespace), with snapshot class `miroir-snap` |
| `media-nfs` | `home` | Static NFS PersistentVolume on the NAS |

## NFS

The `home` cluster mounts the Synology NAS over NFS: a static 60Ti `ReadWriteMany` PersistentVolume (`media-nfs`) pointing at `${STORAGE_IP}:/volume2/media`, claimed in the `media` namespace and shared by the media apps. Manifest: [kubernetes/home/apps/media/media-nfs](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/home/apps/media/media-nfs).

## Backups

PVC backups in the `home` cluster are handled by [kopiur](../apps/platform/kopiur.md) (a Kopia-based operator): apps opt in via the `components/kopiur/backup` kustomize component in their `ks.yaml`, which creates a `SnapshotPolicy` and hourly `SnapshotSchedule` targeting the `kopiur-s3` `ClusterRepository` on Hetzner object storage.

<!-- TODO: Document the hcloud cluster's backup strategy (volsync component exists under kubernetes/hcloud/components/volsync). -->
