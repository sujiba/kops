# Flux bootstrap

| | |
|---|---|
| **When** | Right after the [Talos bootstrap](talos-bootstrap.md) of `home-01` |
| **Duration** | about 15 minutes, then Flux syncs the apps on its own |
| **Risk** | Low: the cluster is fresh, `helmfile sync` can safely be repeated |

## Prerequisites

- [ ] [Talos bootstrap](talos-bootstrap.md) finished, `~/.kube/home` exists
- [ ] Tools installed: `brew install helm helmfile kubectl fluxcd/tap/flux yq`
- [ ] age key at `~/Library/Application Support/sops/age/keys.txt`

## Steps

Run all commands from `kubernetes/bootstrap/home/3_flux`.

1. Create the namespace and store the age key as a secret, so Flux can decrypt the sops secrets:

    ```bash
    kubectl --kubeconfig ~/.kube/home create ns flux-system

    cat $HOME/Library/Application\ Support/sops/age/keys.txt | \
      kubectl create secret generic sops-age \
      --from-file=age.agekey=/dev/stdin \
      -n flux-system --kubeconfig ~/.kube/home
    ```

2. Initialize helmfile:

    ```bash
    helmfile init
    ```

3. Render and apply the CRDs from `0-crds.yaml`:

    ```bash
    helmfile --kubeconfig ~/.kube/home -f 0-crds.yaml template -q \
      | yq ea -e 'select(.kind == "CustomResourceDefinition")' \
      | kubectl --kubeconfig ~/.kube/home apply --server-side --field-manager bootstrap --force-conflicts -f -
    ```

4. Install the base apps from `1-apps.yaml`:

    ```bash
    helmfile --kubeconfig ~/.kube/home -f 1-apps.yaml sync
    ```

5. Trigger Flux once:

    ```bash
    flux reconcile -n flux-system source git flux-system --kubeconfig ~/.kube/home && \
    flux reconcile -n flux-system kustomization flux-system --kubeconfig ~/.kube/home
    ```

| File | Installs |
|---|---|
| `0-crds.yaml` | Only the CRDs of envoy-gateway, grafana-operator, kopiur, kube-prometheus-stack, snapshot-controller |
| `1-apps.yaml` | cilium → cert-manager → cert-manager-webhook-netcup → flux-operator → flux-instance |

## Verify

```bash
kubectl --kubeconfig ~/.kube/home get nodes
flux get kustomizations -A --kubeconfig ~/.kube/home
flux get all -A --status-selector ready=false --kubeconfig ~/.kube/home
```

The node is `Ready` (Cilium is running), and after a while all Kustomizations are `Ready`.

## Rollback

Not needed. All steps are idempotent: on errors, fix the cause and repeat the step.

??? note "Flux cheat sheet"

    ```bash
    # Everything that is not ready
    flux get all -A --status-selector ready=false --kubeconfig ~/.kube/home

    # Watch HelmReleases live
    flux get helmreleases -A --watch --kubeconfig ~/.kube/home

    # Only errors from the Flux logs
    flux logs --all-namespaces --follow --level=error --kubeconfig ~/.kube/home
    ```

    Without `--kubeconfig`, `flux` uses the current context, so when in doubt always pass it.
