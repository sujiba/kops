---
title: sops-age
description: How secrets are encrypted with SOPS and age and decrypted by Flux in the clusters.
---

# sops-age

How to work with SOPS and age in this repository: every secret is encrypted before it is committed, and Flux decrypts it in-cluster. For replacing a key, see [key rotation](key-rotation.md).

Reference: <https://getsops.io/docs/usage/identities/age/>

## Key pair and identity file

SOPS looks for age identities in:

```text
$HOME/Library/Application Support/sops/age/keys.txt
```

(or `$XDG_CONFIG_HOME/sops/age/keys.txt` if `XDG_CONFIG_HOME` is set; can be overridden with `SOPS_AGE_KEY_FILE`). The file can contain multiple identities, one per line; lines starting with `#` are comments. SOPS tries each identity until one can decrypt the data.

Generate a key pair (add `-pq` for a post-quantum key):

```sh
mkdir -p $HOME/Library/Application\ Support/sops/age
age-keygen -o $HOME/Library/Application\ Support/sops/age/keys.txt
```

The helpful VS Code extension `@signageos/vscode-sops` decrypts and re-encrypts files transparently while editing.

## Creation rules

[.sops.yaml](https://code.offene.cloud/homelab/kops/src/branch/main/.sops.yaml) at the repo root decides which recipient key encrypts which path:

| Path | Key | Scope |
| --- | --- | --- |
| `kubernetes/hcloud/**/*.sops.yaml` | classic age key | Only `data`/`stringData` fields |
| `kubernetes/home/**/*.sops.yaml` | post-quantum age key (`age1pq1…`) | Only `data`/`stringData` fields |
| `kubernetes/bootstrap/**/*secrets.yaml` | post-quantum age key | Entire file |

The `encrypted_regex: ^(data|stringData)$` keeps everything except the secret values in plain text, so manifests stay reviewable and diffable. The Talos secrets bundle under `kubernetes/bootstrap/` is encrypted completely.

## Working with secrets

### Create a new secret

Per-app secrets live next to the app as `app/secret.sops.yaml` (a plain `Secret` with `stringData`). Write the manifest in plain text, then encrypt it in place - SOPS picks the matching creation rule from the file path:

```sh
sops encrypt -i kubernetes/home/apps/<namespace>/<app>/app/secret.sops.yaml
```

!!! warning
    Never commit the file before encrypting it. The `stringData` values must show as `ENC[AES256_GCM,…]` in the committed file.

### Edit an existing secret

```sh
# open decrypted in $EDITOR, re-encrypts on save
sops edit kubernetes/home/apps/<namespace>/<app>/app/secret.sops.yaml

# print decrypted to stdout (view only)
sops decrypt kubernetes/home/apps/<namespace>/<app>/app/secret.sops.yaml
```

## In-cluster decryption

Flux decrypts the committed secrets with the `sops-age` Secret in `flux-system`, which holds the age private key and is created manually during [03_flux](../03_flux.md). Every apps Kustomization gets `spec.decryption.provider: sops` from `kubernetes/<cluster>/flux/cluster.yaml`, which also patches the setting into all child Kustomizations - individual apps never configure decryption themselves.
