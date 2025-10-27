# Create talos node on hcloud <!-- omit in toc -->

- [Required packages](#required-packages)
  - [Helpful vscode extension](#helpful-vscode-extension)
- [Create Talos Node](#create-talos-node)

## Required packages
```bash
brew install opentofu
```

### Helpful vscode extension
```bash
vscode extension OpenTofu (official)
```

## Create Talos Node
Change into the directory `1_opentofu`

```bash
# Asks for tofu passphrase to encrypt the state file
tofu init
tofu validate
TF_VAR_tofu_passphrase="" tofu plan
TF_VAR_tofu_passphrase="" tofu apply
TF_VAR_tofu_passphrase="" tofu destroy
```
