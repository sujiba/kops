# Bootstrap k8s <!-- omit in toc -->

- [Required packages](#required-packages)
- [Prerequisites](#prerequisites)
  - [Create Namespaces](#create-namespaces)
  - [Add sops private key](#add-sops-private-key)
  - [Create secrets](#create-secrets)
  - [Prepare k8s for fluxcd bootstrap](#prepare-k8s-for-fluxcd-bootstrap)
  - [Create a dedicated forgejo user for flux](#create-a-dedicated-forgejo-user-for-flux)
- [Bootstrap k8s cluster with flux](#bootstrap-k8s-cluster-with-flux)

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

### Prepare k8s for fluxcd bootstrap
```bash
# initiate helmfile
helmfile init

# sync before apply, to install crds
helmfile sync
helmfile apply
```

### Create a dedicated forgejo user for flux
If you want to host your k8s repo that is owned by a forgejo organization, FluxCD recommends to use a dedicated user under the organization. Additionaly you have to create a PAT for this user with the following permissions:
```bash
- read:misc
- write:repository
```

## Bootstrap k8s cluster with flux
```bash
flux reconcile -n flux-system source git flux-system

flux reconcile -n flux-system kustomization flux-system
```