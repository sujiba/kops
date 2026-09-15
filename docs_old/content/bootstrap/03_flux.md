---
title: 03_flux
description: Bootstrap Flux on the home cluster and hand over to GitOps.
---

# 03_flux

Installs the CRDs and the initial apps on the `home` cluster and hands reconciliation over to Flux. The authoritative files live in [kubernetes/bootstrap/home/3_flux](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/bootstrap/home/3_flux).

## Required packages

```bash
brew install helm helmfile kubectl fluxcd/tap/flux yq
```

## Prerequisites

Change into the directory `kubernetes/bootstrap/home/3_flux`.

### Create namespaces

```bash
# create namespace upfront to apply secrets
kubectl --kubeconfig ~/.kube/home create ns flux-system
```

### Add sops private key

```bash
cat $HOME/Library/Application\ Support/sops/age/keys.txt | \
  kubectl create secret generic sops-age \
  --from-file=age.agekey=/dev/stdin \
  -n flux-system --kubeconfig ~/.kube/home
```

## Prepare k8s and bootstrap fluxcd

```bash
# initiate helmfile
helmfile init

# render all necessary crds
helmfile --kubeconfig ~/.kube/home -f 0-crds.yaml template -q | yq ea -e 'select(.kind == "CustomResourceDefinition")' | kubectl --kubeconfig ~/.kube/home apply --server-side --field-manager bootstrap --force-conflicts -f -

# sync helm
helmfile --kubeconfig ~/.kube/home -f 1-apps.yaml sync
```

## Flux reconcile

!!! tip
    Flux needs a cluster reference. Set it with `--kubeconfig ~/.kube/home`.

`flux reconcile` checks if there are any changes that should be deployed into the cluster.

```bash
# reconcile source git repo and all kustomizations
flux reconcile -n flux-system source git flux-system --kubeconfig ~/.kube/home && \
flux reconcile -n flux-system kustomization flux-system --kubeconfig ~/.kube/home
```

## Flux cheat sheet

Helpful commands:

```bash
flux get all -A --status-selector ready=false --kubeconfig ~/.kube/home

flux get helmreleases --all-namespaces --watch --kubeconfig ~/.kube/home

flux logs --all-namespaces --follow --level=error
```
