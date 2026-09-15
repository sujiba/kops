---
title: key rotation
description: Replacing an old age key with a new post-quantum age key and re-encrypting all SOPS secrets.
---

# key rotation

This guide describes how to replace an old age key with a **new post-quantum (PQ) age key** and re-encrypt all SOPS secrets for the new key. For the general setup and the identity file location, see [sops-age](sops-age.md).

Reference: <https://getsops.io/docs/usage/identities/age/>

## Prerequisites

- `age` / `age-keygen` with post-quantum support (`-pq` flag)
- `sops` with support for PQ age recipients (`age1pq1…`)
- The **old private key** must still be available - SOPS needs it to decrypt the files before re-encrypting them for the new key.

## Generate a new key

```sh
age-keygen -pq -o $HOME/Library/Application\ Support/sops/age/keys.new.txt
```

The public key (recipient) is printed to the terminal and is also contained as a comment in the file:

```text
# public key: age1pq1<NEW>…
AGE-SECRET-KEY-PQ-1…
```

## Add the new key to the identities file

Copy the content of `keys.new.txt` into `keys.txt`. **Append it - do not replace the old key yet**, otherwise the existing secrets can no longer be decrypted.

```sh
cd $HOME/Library/Application\ Support/sops/age
cat keys.new.txt >> keys.txt
```

## Update the creation rules

In [.sops.yaml](https://code.offene.cloud/homelab/kops/src/branch/main/.sops.yaml), remove the old public key and add the new one. Replace **every** occurrence - the same key may be used in several rules (e.g. `kubernetes/home/…` and `kubernetes/bootstrap/…` share the PQ key).

Before:

```yaml
creation_rules:
  - path_regex: kubernetes/home/.*\.sops\.ya?ml
    encrypted_regex: "^(data|stringData)$"
    key_groups:
      - age:
          - age1pq1<OLD>…            # old key
  - path_regex: kubernetes/bootstrap/.*secrets\.yaml
    key_groups:
      - age:
          - age1pq1<OLD>…            # old key
```

After:

```yaml
creation_rules:
  - path_regex: kubernetes/home/.*\.sops\.ya?ml
    encrypted_regex: "^(data|stringData)$"
    key_groups:
      - age:
          - age1pq1<NEW>…            # new key
  - path_regex: kubernetes/bootstrap/.*secrets\.yaml
    key_groups:
      - age:
          - age1pq1<NEW>…            # new key
```

## Update the keys in the encrypted files

```sh
sops updatekeys secrets.sops.yaml
```

SOPS shows the planned changes and asks for confirmation:

```text
The following changes will be made to the file's groups:
Group 1
--- age1pq1<OLD>…
+++ age1pq1<NEW>…
Is this okay? (y/n):
```

This swaps the keys: the file's data key is decrypted with the old identity and re-encrypted for the recipients currently defined in `.sops.yaml`.

Run this for **every** file matched by the affected rules. Example for all files at once (`-y` skips the confirmation):

```sh
find kubernetes/home -name '*.sops.yaml' -exec sops updatekeys -y {} \;
find kubernetes/bootstrap -name '*secrets.yaml' -exec sops updatekeys -y {} \;
```

## Verify with the new key only

Make sure the files can be decrypted using only the new key:

```sh
SOPS_AGE_KEY_FILE=$HOME/Library/Application\ Support/sops/age/keys.new.txt \
  sops decrypt secrets.sops.yaml > /dev/null && echo OK
```

## Clean up

Once all files have been updated and verified:

- Remove the old identity from `keys.txt`.
- Delete `keys.new.txt` (its content is now in `keys.txt`).
- Update the key anywhere else it is used (e.g. the `sops-age` secret in the cluster for Flux, CI secrets, password manager backup).
- Commit `.sops.yaml` and the updated secret files.

## Updatekeys vs rotate

`sops updatekeys` only changes **who** can decrypt the file - the underlying data key stays the same. Anyone who still has the old private key and an old version of the file (e.g. from Git history) can still read it.

If the old key may be compromised, additionally rotate the data key and change the actual secret values:

```sh
sops rotate -i secrets.sops.yaml
```
