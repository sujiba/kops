<div align="center">

# K(ubernetes) Op(eration)s <!-- omit in toc -->

_... managed by FluxCD, Renovate, and Forgejo Actions_ 🤖

[![Discord](https://img.shields.io/discord/673534664354430999?style=for-the-badge&label&logo=discord&logoColor=white&color=5A65EA)](https://discord.gg/k8s-at-home)
[![Renovate](https://img.shields.io/badge/Renovate-193B87?style=for-the-badge&logo=renovate&logoColor=white)](https://www.mend.io/renovate/)
[![Forgejo](https://img.shields.io/badge/Forgejo-EC622A?style=for-the-badge&logo=forgejo&logoColor=white)](https://forgejo.org)

_hcloud cluster stats:_

[![Talos](https://kromgo.offene.cloud/badges/talos_version)](https://talos.dev)
[![Kubernetes](https://kromgo.offene.cloud/badges/kubernetes_version)](https://kubernetes.io)
[![Flux](https://kromgo.offene.cloud/badges/flux_version)](https://fluxcd.io)


html<a href="https://talos.dev"><img src="https://kromgo.offene.cloud/badges/talos_version" height="25"></a>
<a href="https://kubernetes.io"><img src="https://kromgo.offene.cloud/badges/kubernetes_version" height="25"></a>
<a href="https://fluxcd.io"><img src="https://kromgo.offene.cloud/badges/flux_version" height="25"></a>

[![Talos](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/talos_version&style=for-the-badge&logo=talos&logoColor=white&color=D14459&label=%20)](https://talos.dev)
[![Kubernetes](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/kubernetes_version&style=for-the-badge&logo=kubernetes&logoColor=white&color=416BDD&label=%20)](https://kubernetes.io)
[![Flux](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/flux_version&style=for-the-badge&logo=flux&logoColor=white&color=416BDD&label=%20)](https://fluxcd.io)

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
