# Bootstrap talos with the help of talhelper <!-- omit in toc -->

- [Required packages](#required-packages)
  - [Helpful vscode extension](#helpful-vscode-extension)
- [Configure sops and age](#configure-sops-and-age)
- [talhelper](#talhelper)
  - [Encryption setup](#encryption-setup)
  - [talos secret](#talos-secret)
  - [talhelper environment vars](#talhelper-environment-vars)
  - [talconfig.yaml](#talconfigyaml)
  - [talhelper genconfig](#talhelper-genconfig)
- [Cluster bootstrap](#cluster-bootstrap)

## Required packages
```bash
brew install talosctl talhelper sops age
```

### Helpful vscode extension
```bash
vscode extension @signageos/vscode-sops
```

## Configure sops and age
```bash
# When decrypting a file with the corresponding identity, SOPS will look for a text 
# file named keys.txt located in a sops subdirectory of your user configuration directory.
mkdir -p $HOME/Library/Application\ Support/sops/age

# Generate the key pair
age-keygen -o  $HOME/Library/Application\ Support/sops/age/keys.txt
```

## talhelper
Change into the directory `setup/home/talos`

### Encryption setup
Create the file `.sops.yaml` and copy the following content into it. Replace `YOUR_PULBIC_AGE_KEY` with the public key that you can find in your previously genereted keys.txt.

> [!NOTE]
> Do not change the indentation!

```yaml
---
creation_rules:
  - age: >-
      YOUR_PULBIC_AGE_KEY
```

### talos secret
Generate and encrypt your new talos secret.
```bash
talhelper gensecret > talsecret.sops.yaml

sops -e -i talsecret.sops.yaml
```

> [!CAUTION]
> Do not update or change `talsecret.sops.yaml`.

### talhelper environment vars
Create and encrypt the talenv.yaml to store sensitive data used during `talhelper genconfig`
```bash
vi talenv.yaml

sops -e -i talenv.yaml
```

### talconfig.yaml
Create a talconfig.yaml. Take inspiration from the [talhelper template](https://github.com/budimanjojo/talhelper/blob/master/example/talconfig.yaml) and the [configuration parameters](https://budimanjojo.github.io/talhelper/latest/reference/configuration/).

```bash
vi talconfig.yaml
```

### talhelper genconfig

> [!CAUTION]
> The `.gitignore` contains all genereted files from `talhelper genconfig` because those files contain unencrypted secrets.

The command `talhelper genconfig` will create a `.gitignore`, `talosconfig` and `CLUSTERNAME_HOSTNAMEs.yaml` under clusterconfig.

## Cluster bootstrap

> [!TIP]
> After booting talos from usb, change with F3 into network and configure a static ip adress

```bash
talosctl apply-config --insecure -n IP_ADDRESS --file clusterconfig/clustername-host.yaml
talosctl bootstrap -n IP_ADDRESS -e IP_ADDRESS --talosconfig clusterconfig/talosconfig
talosctl -n IP_ADDRESS --talosconfig clusterconfig/talosconfig kubeconfig
```
