# Bootstrap talos with the help of topf <!-- omit in toc -->

- [Required packages](#required-packages)
  - [Helpful vscode extension](#helpful-vscode-extension)
- [Configure sops and age](#configure-sops-and-age)
- [topf](#topf)
  - [Encryption setup](#encryption-setup)
  - [talos secrets](#talos-secrets)
  - [topf.yaml](#topfyaml)
  - [schematic.yaml](#schematicyaml)
  - [Patches](#patches)
- [Hardware notes](#hardware-notes)
- [Cluster bootstrap](#cluster-bootstrap)

## Required packages
```bash
brew install talosctl sops age postfinance/tap/topf
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
age-keygen -o $HOME/Library/Application\ Support/sops/age/keys.txt
```

## topf
Change into the directory `bootstrap/home/2_talos`.

### Encryption setup
Encryption rules for this directory live in the repo-wide `.sops.yaml`. The rule defined there fully encrypts `secrets.yaml`.

### talos secrets
Generate and encrypt the Talos secrets bundle.
```bash
topf secrets --confirm=false > secrets.yaml
```

> [!CAUTION]
> Do not update or change `secrets.yaml`.

### topf.yaml
`topf.yaml` holds cluster identity, versions, node list, and a `data:` block for values referenced by the patch templates (`.tpl` files).

### schematic.yaml
`schematic.yaml` defines the Image Factory schematic: system extensions and kernel command-line args baked into the installer image. topf uploads it and exposes the resulting ID as `{{ .schematicId }}` in the patches.

Extensions in use:

| Extension | Why |
| --- | --- |
| `siderolabs/intel-ucode` | Intel CPU microcode updates |
| `siderolabs/xe` | Intel Xe driver for the Arrow Lake-H iGPU (Arc 130T) - required for Jellyfin hardware transcoding |
| `siderolabs/binfmt-misc` | QEMU emulation for building arm64 container images on this amd64 node |
| `siderolabs/drbd` | DRBD kernel module, loaded via `KernelModuleConfig` for replicated block storage |

Kernel args in use:

| Arg | Why |
| --- | --- |
| `xe.enable_guc=3` | GuC/HuC submission for the Xe iGPU |
| `intel_iommu=on`, `iommu=pt` | IOMMU passthrough mode |
| `initcall_blacklist=algif_aead_init` | Mitigates CVE-2026-31431 ("Copy Fail") on kernels where `algif_aead` is built in |
| `lsm=lockdown,capability,yama,safesetid,bpf,landlock` | Drops permissive-only SELinux (which floods the audit log without enforcing) while keeping the minor LSMs |
| `sysctl.kernel.kexec_load_disabled=1` | Blocks runtime kexec |

### Patches
Machine config is assembled from small strategic-merge patch files instead of one monolithic config:
- `all/` - patches applied to every node
- `control-plane/` - patches applied to control-plane nodes
- `node/<host>/` - patches applied to a single node
- `worker/` - patches applied to worker nodes

Files ending in `.tpl` are rendered as Go templates first (`.Data.<key>`, `.Node.Host`, `.Node.IP`, ...) before being merged.

The onboard NIC is pinned to the alias `net0` via `LinkAliasConfig` matching its permanent MAC. Adding a second NVMe shifts PCI addresses and renames the interface (`enp86s0` → `enp87s0`), which would otherwise leave `LinkConfig` matching nothing and the node off the network.

## Hardware notes

Single node, Intel Core Ultra 5 225H (Arrow Lake-H), Arc 130T iGPU.

- **Install disk** - selected by serial in `UnattendedInstallConfig`. Get it from a node in maintenance mode with `talosctl get disks -n <ip> --insecure -o yaml`.
- **`miroir` raw volume** - carved from the non-system WD_BLACK SN770 2TB for a CSI provisioner. The `!system_disk` guard is only populated after installation completes, so expect an error about it on the very first boot.
- **NTP** - sourced from the local gateway. kubelet and etcd block on time sync before starting, so a router that isn't actually serving NTP will hang the boot rather than fail loudly.

## Cluster bootstrap

> [!TIP]
> After booting talos from usb, change with F3 into network and configure a static ip address

```bash
# render the final machine config offline, without touching any node - good for reviewing changes
topf render

# apply config to the node(s) in maintenance mode and bootstrap etcd
topf apply --auto-bootstrap

# generate credentials
topf talosconfig >  ~/.talos/home
# create kubeconfig with 1 year validity
topf kubeconfig --validity 8760h > ~/.kube/home
```
