---
title: 01_tofu
description: Provision the server infrastructure with OpenTofu.
---

# 01_tofu

Provisions the Talos node infrastructure with OpenTofu. The `home` cluster runs on local hardware, so this phase only applies when a cloud server needs to be created first.

## Required packages

```bash
brew install opentofu
```

Helpful VS Code extension: OpenTofu (official).

## Create the Talos node

Change into the phase directory (`kubernetes/bootstrap/<cluster>/1_tofu`):

```bash
# Asks for tofu passphrase to encrypt the state file
tofu init
tofu validate
TF_VAR_tofu_passphrase="" tofu plan
TF_VAR_tofu_passphrase="" tofu apply
TF_VAR_tofu_passphrase="" tofu destroy
```
