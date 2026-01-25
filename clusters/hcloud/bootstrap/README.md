# Bootstrap k8s<!-- omit in toc -->

- [Required packages](#required-packages)
- [Prerequisites](#prerequisites)
  - [Create Namespaces](#create-namespaces)
  - [Add sops private key](#add-sops-private-key)
  - [Create secrets](#create-secrets)
- [Prepare k8s and bootstrap fluxcd](#prepare-k8s-and-bootstrap-fluxcd)
- [flux reconcile](#flux-reconcile)
- [flux cheat-sheet](#flux-cheat-sheet)

## Required packages
```bash
brew install helm helmfile kubectl fluxcd/tap/flux
```

## Prerequisites
Change into the directory `clusters/hcloud/bootstrap`

### Create Namespaces
```bash
# create namespace upfront to apply secrets
kubectl create ns flux-system
kubectl create ns development
```

### Add sops private key
```bash
cat $HOME/Library/Application\ Support/sops/age/keys.txt | \
  kubectl create secret generic sops-age \
  --from-file=age.agekey=/dev/stdin \
  -n flux-system --kubeconfig ~/.kube/hcloud
```

### Create secrets
```bash
# Do not forget to encrypt all your *.sops.yaml files
mv bootstrap.secrets.sops.yaml_example bootstrap.secrets.sops.yaml

# in-place encrypt secrets file, so we can store them in our git repo
sops encrypt -i bootstrap.secrets.sops.yaml

# Apply secrets to cluster
sops --decrypt bootstrap.secrets.sops.yaml | kubectl apply -f -
```

## Prepare k8s and bootstrap fluxcd 
```bash
# initiate helmfile
helmfile init

# render all necessary crds
helmfile -f 0-crds.yaml template -q | yq ea -e 'select(.kind == "CustomResourceDefinition")' | kubectl --kubeconfig ~/.kube/hcloud apply --server-side --field-manager bootstrap --force-conflicts -f -

# sync helm
helmfile -f 1-apps.yaml sync
```

## flux reconcile
> [!TIP]
> flux needs a cluster reference. Set it with `--kubeconfig ~/.kube/hcloud`

`flux reconcile` checks, if there are any changes that should be deployed into the cluster.

```bash
# reconcile source git repo and all kustomizations
flux reconcile -n flux-system source git flux-system --kubeconfig ~/.kube/hcloud && \
flux reconcile -n flux-system kustomization flux-system --kubeconfig ~/.kube/hcloud
```

## flux cheat-sheet
Helpful commands:
```bash
flux get all -A --status-selector ready=false --kubeconfig ~/.kube/home

flux get helmreleases --all-namespaces --watch --kubeconfig ~/.kube/home

flux logs --all-namespaces --follow --level=error
```
