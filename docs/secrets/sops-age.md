# SOPS – Rotating a post-quantum age key <!-- omit in toc -->

This guide describes how to replace an **old post-quantum (PQ) age key** with a **new PQ age key** and re-encrypt all SOPS secrets for the new key.

> Public keys in this document are shortened (`age1pq1nfmv…2afe`) for readability. PQ recipients are very long – always copy the full key.

Reference: <https://getsops.io/docs/usage/identities/age/>

## Overview <!-- omit in toc -->
- [Prerequisites](#prerequisites)
- [Key location (macOS)](#key-location-macos)
- [1. Generate a new key](#1-generate-a-new-key)
- [2. Add the new key to `keys.txt`](#2-add-the-new-key-to-keystxt)
- [3. Update `.sops.yaml` (creation rules)](#3-update-sopsyaml-creation-rules)
- [4. Update the keys in the encrypted files](#4-update-the-keys-in-the-encrypted-files)
- [5. Verify with the new key only](#5-verify-with-the-new-key-only)
- [6. Clean up](#6-clean-up)
- [Note: `updatekeys` vs. `rotate`](#note-updatekeys-vs-rotate)

## Prerequisites

- `age` / `age-keygen` with post-quantum support (`-pq` flag)
- `sops` with support for PQ age recipients (`age1pq1…`)
- The **old private key** must still be available – SOPS needs it to decrypt the files before re-encrypting them for the new key.

## Key location (macOS)

SOPS looks for age identities in:

```
$HOME/Library/Application Support/sops/age/keys.txt
```

(or `$XDG_CONFIG_HOME/sops/age/keys.txt` if `XDG_CONFIG_HOME` is set; can be overridden with `SOPS_AGE_KEY_FILE`).

The file can contain multiple identities, one per line. Lines starting with `#` are comments. SOPS tries each identity until one can decrypt the data.

## 1. Generate a new key

```sh
age-keygen -pq -o $HOME/Library/Application\ Support/sops/age/keys.neu.txt
```

The public key (recipient) is printed to the terminal and is also contained as a comment in the file:

```
# public key: age1pq1<NEW>…
AGE-SECRET-KEY-PQ-1…
```

## 2. Add the new key to `keys.txt`

Copy the content of `keys.neu.txt` into `keys.txt`. **Append it – do not replace the old key yet**, otherwise the existing secrets can no longer be decrypted.

```sh
cd $HOME/Library/Application\ Support/sops/age
cat keys.neu.txt >> keys.txt
```

## 3. Update `.sops.yaml` (creation rules)

Remove the old public key and add the new one. Replace **every** occurrence – the same key may be used in several rules.

Before:

```yaml
creation_rules:
  - path_regex: kubernetes/hcloud/.*\.sops\.ya?ml
    encrypted_regex: "^(data|stringData)$"
    key_groups:
      - age:
          - age1yqc8cmp2…rf20ud
  - path_regex: kubernetes/home/.*\.sops\.ya?ml
    encrypted_regex: "^(data|stringData)$"
    key_groups:
      - age:
          - age1pq1nfmv…2afe        # old key
  - path_regex: kubernetes/bootstrap/.*secrets\.yaml
    key_groups:
      - age:
          - age1pq1nfmv…2afe        # old key
```

After:

```yaml
creation_rules:
  - path_regex: kubernetes/hcloud/.*\.sops\.ya?ml
    encrypted_regex: "^(data|stringData)$"
    key_groups:
      - age:
          - age1yqc8cmp2…rf20ud
  - path_regex: kubernetes/home/.*\.sops\.ya?ml
    encrypted_regex: "^(data|stringData)$"
    key_groups:
      - age:
          - age1pq1<NEW>…           # new key
  - path_regex: kubernetes/bootstrap/.*secrets\.yaml
    key_groups:
      - age:
          - age1pq1<NEW>…           # new key
```

## 4. Update the keys in the encrypted files

```sh
sops updatekeys secrets.sops.yaml
```

SOPS shows the planned changes and asks for confirmation:

```
The following changes will be made to the file's groups:
Group 1
--- age1pq1nfmv…2afe
+++ age1pq1<NEW>…
Is this okay? (y/n):
```

This swaps the keys: the file's data key is decrypted with the old identity and re-encrypted for the recipients currently defined in `.sops.yaml`.

Run this for **every** file matched by the affected rules. Example for all files at once (`-y` skips the confirmation):

```sh
find kubernetes/home -name '*.sops.yaml' -exec sops updatekeys -y {} \;
find kubernetes/bootstrap -name '*secrets.yaml' -exec sops updatekeys -y {} \;
```

## 5. Verify with the new key only

Make sure the files can be decrypted using only the new key:

```sh
SOPS_AGE_KEY_FILE=$HOME/Library/Application\ Support/sops/age/keys.neu.txt \
  sops decrypt secrets.sops.yaml > /dev/null && echo OK
```

## 6. Clean up

Once all files have been updated and verified:

- Remove the old identity from `keys.txt`.
- Delete `keys.neu.txt` (its content is now in `keys.txt`).
- Update the key anywhere else it is used (e.g. the `sops-age` secret in the cluster for Flux/ArgoCD, CI secrets, password manager backup).
- Commit `.sops.yaml` and the updated secret files.

## Note: `updatekeys` vs. `rotate`

`sops updatekeys` only changes **who** can decrypt the file – the underlying data key stays the same. Anyone who still has the old private key and an old version of the file (e.g. from Git history) can still read it.

If the old key may be compromised, additionally rotate the data key and change the actual secret values:

```sh
sops rotate -i secrets.sops.yaml
```
