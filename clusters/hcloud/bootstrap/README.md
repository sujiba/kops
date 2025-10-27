# Bootstrap k8s <!-- omit in toc -->

- [Required packages](#required-packages)
- [Prerequisites](#prerequisites)
  - [Create Namespaces](#create-namespaces)
  - [Add sops private key](#add-sops-private-key)
  - [Create secrets](#create-secrets)
- [Prepare k8s and bootstrap fluxcd](#prepare-k8s-and-bootstrap-fluxcd)
- [flux reconcile](#flux-reconcile)

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

## Prepare k8s and bootstrap fluxcd 
```bash
# initiate helmfile
helmfile init

# sync before apply, to install crds
helmfile sync
helmfile apply
```

## flux reconcile
> [!TIP]
> Keep in Mind that flux needs a cluster referenc with --kubeconfig ~/.kube/hcloud

`flux reconcile` checks, if there are any changes that should be deployed into the cluster.

```bash
# reconcile source git repo
flux reconcile -n flux-system source git flux-system --kubeconfig ~/.kube/hcloud

# reconcile all kustomizations
flux reconcile -n flux-system kustomization flux-system --kubeconfig ~/.kube/hcloud
```