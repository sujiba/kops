# Bootstrap k8s <!-- omit in toc -->

- [Required packages](#required-packages)
- [Prerequisites](#prerequisites)
  - [Create secrets](#create-secrets)
  - [Prepare k8s for bootstrap](#prepare-k8s-for-bootstrap)
- [Bootstrap k8s cluster with argocd](#bootstrap-k8s-cluster-with-argocd)
  - [Get argocd intial admin password](#get-argocd-intial-admin-password)
  - [Create argocd appset](#create-argocd-appset)

## Required packages
```bash
brew install helm helmfile kubectl
```

## Prerequisites
Change into the directory `clusters/hcloud/bootstrap`

### Create secrets
```bash
# Every file that ends with .secrets.yaml gets ignored by git
mv forgejo.secrets.yaml_example forgejo.secrets.yaml

# create namespace upfront to apply secrets
kubectl create ns forgejo
kubectl -n forgejo apply -f forgejo.secrets.yaml 
```

### Prepare k8s for bootstrap
```bash
# initiate helmfile
helmfile init

# sync before apply, to install crds
helmfile sync
helmfile apply
```

## Bootstrap k8s cluster with argocd
```bash
brew install argocd
```

### Get argocd intial admin password
```bash
# Use secret to login as admin and change password
kubectl -n argocd get secret argocd-initial-admin-secret \
        -o jsonpath="{.data.password}" | base64 -d; echo

# Login to argocd
argocd login argocd.domain.tld
# Change admin password
argocd account update-password

# After password change, delete secret
kubectl -n argocd delete secret argocd-initial-admin-secret
```

### Create argocd appset
```bash
kubectl apply -k clusters/hcloud/apps
```