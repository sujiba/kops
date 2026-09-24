# Talos upgrade

| | |
|---|---|
| **When** | New Talos version available, Renovate opened a PR for `siderolabs/talos` |
| **Duration** | about 10–15 minutes per node |
| **Risk** | Medium: both clusters are single-node, the cluster is unreachable during the reboot |

## Prerequisites

- [ ] Changelog of the target version read (breaking changes, Kubernetes compatibility)
- [ ] Local `talosctl` at the target version or newer
- [ ] `talosconfig` and `kubeconfig` for the cluster available
- [ ] Recent backups (kopiur) completed successfully
- [ ] No other work on the cluster in progress

!!! warning "Only one node at a time"

    Never upgrade several nodes in parallel. With our single-node clusters this also means: every upgrade is downtime for all services of that cluster.

## Steps

The version appears in several places, and Renovate updates them together. tuppr is the default path, topf is the manual fallback.

=== "tuppr (default)"

    1. Review the Renovate PR. It changes the version in
        - `kubernetes/<cluster>/apps/system-upgrade/tuppr/upgrades/talos.yaml`
        - `kubernetes/bootstrap/<cluster>/2_talos/topf.yaml`
    2. Merge the PR. Flux applies the `TalosUpgrade`, tuppr runs the upgrade.
    3. Follow the progress:

        ```bash
        kubectl get talosupgrade -A -w
        ```

=== "topf (manual)"

    ```bash
    cd kubernetes/bootstrap/<cluster>/2_talos
    topf render   # review changes offline
    topf upgrade
    ```

## Verify

```bash
talosctl version -n <node-ip>
talosctl etcd status -n <node-ip>
kubectl get nodes -o wide
```

The node must be `Ready`, and the server version must match the target version.

## Rollback

```bash
talosctl rollback -n <node-ip>
```

Then revert the version in the files listed above, otherwise tuppr starts the upgrade again.

??? note "Background: how Talos upgrades"

    Talos has two boot partitions (A/B). An upgrade writes the new image to the inactive partition and boots from it. `talosctl rollback` simply switches back to the previous partition. That is why a rollback is fast, but it only goes back one step.

    tuppr is a controller that runs `TalosUpgrade` and `KubernetesUpgrade` resources. This keeps upgrades GitOps-driven instead of running from a laptop.
