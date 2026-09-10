# Manual Kopiur restore into an existing PVC <!-- omit in toc -->

- [Background](#background)
- [Identify the snapshot](#identify-the-snapshot)
- [Manifest](#manifest)
- [Procedure](#procedure)
  - [1. Stop the app](#1-stop-the-app)
  - [2. Apply the manifest and watch the restore](#2-apply-the-manifest-and-watch-the-restore)
  - [3. Start the app again](#3-start-the-app-again)
  - [4. Clean up](#4-clean-up)
- [Behavior with existing data](#behavior-with-existing-data)
- [Cautious variant: restore into a new PVC first](#cautious-variant-restore-into-a-new-pvc-first)
- [Troubleshooting](#troubleshooting)
- [After the restore: future backups](#after-the-restore-future-backups)


This guide restores a kopia snapshot directly into an existing PVC using a `Restore`. Use it when the automatic deploy-or-restore (populator) finds no snapshot, typically after moving an app to a different namespace.

## Background

Kopia stores every snapshot under the identity `username@hostname:path`. Kopiur sets `username` to the name of the `SnapshotPolicy` and `hostname` to the namespace by default. When an app moves to a new namespace, the populator restore looks under the new identity, finds nothing, and provisions an empty volume (`NoSnapshotContinue`).

A manual `Restore` with an explicit `source.identity` lets you point at the old identity directly.

## Identify the snapshot

Before restoring, confirm that snapshots actually exist under the old identity. The output of `kopia snapshot list --all` against the repository should contain a line like this:

```text
<APP>@<OLD_NAMESPACE>:/pvc/<APP>
```

If the PVC had a different name back then, `sourcePath` in the manifest must point to the old name, not the new one.

## Manifest

Save the manifest as `restore-manual.yaml`.

```yaml
---
apiVersion: kopiur.home-operations.com/v1alpha1
kind: Restore
metadata:
  name: APP-manual
  namespace: NAMESPACE
spec:
  # Required for an identity source: there is no policy to infer the repository from.
  repository:
    kind: ClusterRepository
    name: kopiur-s3

  source:
    identity:
      # Kopia username: the name of the SnapshotPolicy that wrote the snapshots.
      username: APP
      # Kopia hostname: the OLD namespace the snapshots were written from.
      hostname: OLD_NAMESPACE
      # Kopia source path: PVC sources are recorded as /pvc/<pvcName>.
      sourcePath: /pvc/APP
      # Optional: pin an exact snapshot instead of restoring the latest one.
      # snapshotID: <id>

  target:
    pvcRef: 
      # Existing PVC in this namespace. The app must be scaled to 0 before restoring.
      name: APP

  options:
    # Mirror the snapshot exactly: delete files in the target that are not in the snapshot.
    # Prevents stale SQLite -wal/-shm files from a fresh instance mixing with the restored DB.
    enableFileDeletion: true

  mover:
    # Own the restored files as the app's UID/GID (default mover UID is 65532).
    securityContext:
      runAsUser: 1000
      runAsGroup: 1000
    # Make the volume group-writable for the app's group.
    podSecurityContext:
      fsGroup: 1000

  policy:
    # Fail loudly instead of silently leaving the volume empty.
    onMissingSnapshot: Fail
```

## Procedure

### 1. Stop the app

Suspend the HelmRelease first, otherwise Flux scales the Deployment back up on the next reconcile.

```bash
flux -n NAMESPACE suspend hr APP
kubectl -n NAMESPACE scale deploy/APP --replicas=0
```

Wait until no pod of the app is running anymore:

```bash
kubectl -n NAMESPACE get pods
```

As long as the app is writing to its database, even mirror mode won't help, so only continue once the pod is gone.

### 2. Apply the manifest and watch the restore

Apply:

```bash
kubectl apply -f restore-manual.yaml

kubectl -n NAMESPACE get restore APP-manual -w
```

The phases go `Resolving`, then `Restoring`, then `Completed`.

### 3. Start the app again

```bash
flux -n NAMESPACE resume hr APP
flux -n NAMESPACE scale deploy/APP --replicas=0
```

Check the contents (adjust the container name):

```bash
kubectl -n NAMESPACE exec deploy/APP -c <container> -- ls -la /config
```

### 4. Clean up

A restore with `pvcRef` is one-shot and finished once it reaches `Completed`. The object can be deleted; the data stays in the PVC.

```bash
kubectl -n NAMESPACE delete restore APP-manual
```

Don't commit the manifest to Git, otherwise Flux would recreate it on every reconcile.

## Behavior with existing data

Without `enableFileDeletion`, a restore is additive: files from the snapshot overwrite files with the same name in the PVC, and all other files are left in place. For SQLite-based apps (Sonarr, Radarr, Prowlarr) this is risky, because leftover `-wal`/`-shm` files from a fresh instance can corrupt the restored database.

With `enableFileDeletion: true`, the **entire PVC** becomes an exact mirror of the snapshot. Anything created after the backup is gone afterwards.

## Cautious variant: restore into a new PVC first

To inspect the contents before overwriting anything, replace the `target` block with a new PVC and drop the `options` block:

```yaml
  target:
    pvc:
      # New PVC created by the operator next to the original one.
      name: APP-restored
      # Required: must be at least as large as the backed-up data.
      capacity: 20Gi
```

Once you have checked it, delete the test PVC and run the actual restore with `pvcRef`. The PVC created by Kopiur is not owned by the `Restore` and survives deleting the restore, so it has to be removed separately.

## Troubleshooting

```bash
kubectl -n NAMESPACE describe restore APP-manual
```

The most common causes:

- **Snapshot not found:** `username`, `hostname` or `sourcePath` don't match the identity in the repository. Cross-check with `kopia snapshot list --all`.
- **Repository not found:** wrong name or wrong `kind` (`Repository` instead of `ClusterRepository` or the other way around).
- **Mover doesn't start:** the PVC is still held by a running pod, or the repository credentials are missing in the namespace.
- **App can't read its files:** `APP_UID`/`APP_GID` don't match the app's `securityContext`.

## After the restore: future backups

By default, new backups from the new namespace are written under `<APP>@<NAMESPACE>` as a new history. The old snapshots under `<APP>@<OLD_NAMESPACE>` remain in the repository.

To continue the old history instead, set `spec.identity` in the `SnapshotPolicy` to `username: <APP>` and `hostname: <OLD_NAMESPACE>`. In that case, no policy in the old namespace may still back up under the same identity, otherwise the snapshot history gets corrupted.

Don't rely on the backups until the first successful backup run in the new namespace has completed.
