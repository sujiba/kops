---
icon: lucide/rocket
---

# Talos bootstrap

| | |
|---|---|
| **When** | Set up `home-01` from scratch: new hardware, total loss or full rebuild of the cluster `home` |
| **Duration** | about 30 minutes |
| **Risk** | High: the cluster `home` is recreated, all services are gone until the [Flux bootstrap](flux-bootstrap.md) is done |

## Prerequisites

- [ ] Tools installed: `brew install talosctl sops age postfinance/tap/topf`
- [ ] age key at `~/Library/Application Support/sops/age/keys.txt` (see below)
- [ ] USB stick with the Talos image (Secure Boot) for `home-01`
- [ ] Backups (kopiur) of the apps in the cluster `home` exist

??? note "One-time: set up sops and age"

    SOPS looks for the key in `keys.txt` in the `sops/age` subfolder of the user config directory.

    ```bash
    mkdir -p $HOME/Library/Application\ Support/sops/age
    # generate post-quantum key
    age-keygen -pq -o $HOME/Library/Application\ Support/sops/age/keys.txt
    ```

    The encryption rules live in `.sops.yaml` at the repo root. The VS Code extension `@signageos/vscode-sops` helps with editing.

!!! danger "`secrets.yaml`"

    `kubernetes/bootstrap/home/2_talos/secrets.yaml` holds the Talos secrets bundle (encrypted). Do not change or overwrite it. Only for a brand-new cluster without an existing file:

    ```bash
    topf secrets
    ```

    topf writes the file itself as `secrets.yaml` next to `topf.yaml` and encrypts it automatically thanks to `.sops.yaml`. The additional output on stdout contains the secrets in plain text. `--confirm=false` skips the prompt asking whether to overwrite an existing `secrets.yaml`.

## Steps

Run all commands from `kubernetes/bootstrap/home/2_talos`.

1. Boot the node from the USB stick. In the Talos dashboard, press ++f3++ to open the network menu and set the static IP `10.10.10.4`.
2. Render the config offline and review it, without touching the node:

    ```bash
    topf render
    ```

3. Apply the config and bootstrap etcd:

    ```bash
    topf apply --auto-bootstrap
    ```

4. Generate credentials (kubeconfig valid for one year):

    ```bash
    topf talosconfig > ~/.talos/home
    topf kubeconfig --validity 8760h > ~/.kube/home
    ```

5. Continue with the [Flux bootstrap](flux-bootstrap.md).

## Verify

```bash
talosctl --talosconfig ~/.talos/home health -n 10.10.10.4
kubectl --kubeconfig ~/.kube/home get nodes -o wide
```

!!! info "Node stays `NotReady`"

    This is expected at this point. Flannel and kube-proxy are disabled, the CNI (Cilium) only arrives with the [Flux bootstrap](flux-bootstrap.md).

On the very first boot, Talos reports an error about the `miroir` volume (see hardware below). That is expected too.

## Rollback

There is no rollback as such. With a broken config: fix the patch, check it with `topf render` and run `topf apply` again. If the node hangs completely, boot from the USB stick again and start over at step 1.

## Config layout

| File / folder | Content |
|---|---|
| `topf.yaml` | Cluster name, versions, node list and a `data:` block for the templates |
| `schematic.yaml` | Image Factory schematic: extensions and kernel args, available as `{{ .schematicId }}` in the patches |
| `secrets.yaml` | Talos secrets bundle, encrypted with sops |
| `all/` | Patches for every node |
| `control-plane/` | Patches for control-plane nodes |
| `node/<host>/` | Patches for a single node |
| `worker/` | Patches for worker nodes |

Files ending in `.tpl` are rendered as Go templates first (`.Data.<key>`, `.Node.Host`, `.Node.IP`, ...) and then merged.

??? note "Extensions and kernel args"

    | Extension | Why |
    |---|---|
    | `siderolabs/intel-ucode` | Microcode updates for the Intel CPU |
    | `siderolabs/xe` | Xe driver for the Arc 130T iGPU, required for hardware transcoding in Jellyfin |
    | `siderolabs/binfmt-misc` | QEMU emulation to build arm64 images on the amd64 node |
    | `siderolabs/drbd` | DRBD kernel module for replicated block storage, loaded via `KernelModuleConfig` |

    | Kernel arg | Why |
    |---|---|
    | `xe.enable_guc=3` | GuC/HuC submission for the Xe iGPU |
    | `intel_iommu=on`, `iommu=pt` | IOMMU in passthrough mode |
    | `initcall_blacklist=algif_aead_init` | Mitigates CVE-2026-31431 ("Copy Fail") when `algif_aead` is built into the kernel |
    | `lsm=lockdown,capability,yama,safesetid,bpf,landlock` | Drops permissive-only SELinux (floods the audit log without enforcing), keeps the minor LSMs |
    | `sysctl.kernel.kexec_load_disabled=1` | Blocks kexec at runtime |

??? note "Hardware: `home-01`"

    Single node, Intel Core Ultra 5 225H (Arrow Lake-H) with Arc 130T iGPU.

    - **Install disk:** selected by serial number in `UnattendedInstallConfig`. Read it in maintenance mode with `talosctl get disks -n <ip> --insecure -o yaml`.
    - **Raw volume `miroir`:** lives on the second disk (WD_BLACK SN770 2TB) for a CSI provisioner. The `!system_disk` guard is only populated after installation, hence the error on the first boot.
    - **Network:** the onboard NIC is pinned to the alias `net0` via `LinkAliasConfig` using its MAC. A second NVMe shifts the PCI addresses (`enp86s0` → `enp87s0`); without the alias, `LinkConfig` would match nothing and the node would be offline.
    - **NTP:** comes from the local gateway. kubelet and etcd wait for time sync. If the router does not serve NTP, the boot hangs instead of failing loudly.
