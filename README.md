<div align="center">

# K(ubernetes) Op(eration)s <!-- omit in toc -->

### 🏠 A GitOps-managed Homelab <!-- omit in toc -->

_... powered by [Talos](https://www.siderolabs.com/talos-linux), [Flux](https://fluxcd.io/) and [Kubernetes](https://kubernetes.io/)_

_hcloud cluster stats:_

![Age](https://kromgo.offene.cloud/badges/cluster_birth_age)
![Uptime](https://kromgo.offene.cloud/badges/cluster_uptime_age)
![Nodes](https://kromgo.offene.cloud/badges/cluster_node_count)
![Pods](https://kromgo.offene.cloud/badges/cluster_pod_count)
![CPU](https://kromgo.offene.cloud/badges/cluster_cpu_usage)
![Memory](https://kromgo.offene.cloud/badges/cluster_memory_usage)

</div>


## 📖 Overview
- [📖 Overview](#-overview)
- [⛵ Kubernetes](#-kubernetes)
  - [Installation](#installation)
  - [Directories](#directories)
  - [Networking](#networking)
- [☁ Cloud Dependencies](#-cloud-dependencies)
- [🔧 Hardware](#-hardware)
- [🤝 Special thanks](#-special-thanks)

## ⛵ Kubernetes 
### Installation
1. `git clone https://code.offene.cloud/homelab/k8s.git`
2. [Create talos node on hcloud](bootstrap/hcloud/1_tofu/opentofu/README.md)
3. [Bootstrap talos node](bootstrap/hcloud/2_talos/README.md)
4. [Bootstrap k8s](bootstrap/hcloud/3_flux/README.md)

### Directories
```bash
📁 kops
├─📁 archive
├─📁 bootstrap
│  ├─📁 hcloud
│  │ ├─📁 1_tofu
│  │ ├─📁 2_talos
│  │ └─📁 3_flux
│  └─📁 home
│    ├─📁 2_talos
│    └─📁 3_flux
├─📁 kubernetes         # k8s clusters
│  ├─📁 hcloud          # single node cluster
│  │ ├─📁 apps          # apps sorted by namespaces
│  │ ├─📁 components    # cluster components
│  │ └─📁 flux
│  └─📁 home            # single node cluster
│    ├─📁 apps          # apps sorted by namespaces
│    ├─📁 components    # cluster components
│    └─📁 flux
```

### Networking

## ☁ Cloud Dependencies

| Service | Use             | Cost    |
|---------|-----------------|---------|
| Netcup  | DNS             | ~80€/yr |
| Hetzner | Server / Backup | ~25€/mo |

## 🔧 Hardware

| Device                      | Num | OS Disk Size | Data Disk Size                  | Ram  | OS            | Function                |
|-----------------------------|-----|--------------|---------------------------------|------|---------------|-------------------------|
| ASUS NUC 15 Pro CU 5 225H   | 1   | 2TB SSD      | -                               | 96GB | Talos         | Kubernetes              |
| Synology RS1221+            | 1   | -            | 7x12TB btrfs (SHR-2)            | 4GB  | DSM           | NFS                     |

## 🤝 Special thanks
- [Home Operations discord community](https://discord.gg/home-operations)
- [kubesearch.dev](https://kubesearch.dev/)
- [bjw-s](https://github.com/bjw-s-labs)
- [onedr0p](https://github.com/onedr0p)
- [naoalb](https://code.offene.cloud/lab/k8s)
