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
brew install helm helmfile kubectl fluxcd/tap/flux yq
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
cat $HOME/Library/Application\ Support/sops/age/keys.txt | kubectl create secret generic sops-age --from-file=age.agekey=/dev/stdin -n flux-system
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
helmfile -f 0-crds.yaml template -q | kubectl apply --server-side -f -

# sync before apply, to install crds
helmfile sync
helmfile apply
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
Helpful `flux get` commands:
```bash
# Alle Kustomizations live verfolgen
flux get kustomizations --watch

# Alle Sources (Git, Helm, etc.)
flux get sources all --watch

# Nur Git Sources
flux get sources git --watch

# Helm Releases
flux get helmreleases --watch

# Alles zusammen
flux get all --watch
```

Helpful `flux logs` commands:
```bash
# Alle Flux Logs live
flux logs --all-namespaces --follow

# Nur die letzten 5 Minuten
flux logs --all-namespaces --follow --since=5m

# Nur errors
flux logs --all-namespaces --follow --level=error

# Nur ein bestimmter Controller
flux logs --kind=Kustomization --name=apps --namespace=flux-system

# Source Controller (für Git pulls)
kubectl logs -n flux-system deploy/source-controller --follow

# Kustomize Controller (für deployments)
kubectl logs -n flux-system deploy/kustomize-controller --follow

# Helm Controller (für Helm releases)
kubectl logs -n flux-system deploy/helm-controller --follow
```
