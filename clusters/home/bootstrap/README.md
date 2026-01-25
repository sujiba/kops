# Bootstrap k8s<!-- omit in toc -->

- [Required packages](#required-packages)
- [Prerequisites](#prerequisites)
  - [Create Namespaces](#create-namespaces)
  - [Add sops private key](#add-sops-private-key)
- [Prepare k8s and bootstrap fluxcd](#prepare-k8s-and-bootstrap-fluxcd)
- [flux reconcile](#flux-reconcile)
- [flux cheat-sheet](#flux-cheat-sheet)

## Required packages
```bash
brew install helm helmfile kubectl fluxcd/tap/flux yq
```

## Prerequisites
Change into the directory `clusters/home/bootstrap`

### Create Namespaces
```bash
# create namespace upfront to apply secrets
kubectl create ns flux-system
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
helmfile -f 0-crds.yaml template -q | yq ea -e 'select(.kind == "CustomResourceDefinition")' | kubectl --kubeconfig ~/.kube/home apply --server-side --field-manager bootstrap --force-conflicts -f -

# sync helm
helmfile -f 1-apps.yaml sync
```

## flux reconcile
> [!TIP]
> flux needs a cluster reference. Set it with `--kubeconfig ~/.kube/hcloud`

`flux reconcile` checks, if there are any changes that should be deployed into the cluster.

```bash
# reconcile source git repo and all kustomizations
flux reconcile -n flux-system source git flux-system --kubeconfig ~/.kube/home && \
flux reconcile -n flux-system kustomization flux-system --kubeconfig ~/.kube/home
```

## flux cheat-sheet
Helpful commands:
```bash
flux get all -A --status-selector ready=false --kubeconfig ~/.kube/home

flux get helmreleases --all-namespaces --watch --kubeconfig ~/.kube/home

flux logs --all-namespaces --follow --level=error
```