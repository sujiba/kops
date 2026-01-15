<div align="center">

# K(ubernetes) Op(eration)s <!-- omit in toc -->

_... managed by FluxCD, Renovate, and Forgejo Actions_ 🤖

[![Discord](https://img.shields.io/discord/673534664354430999?style=for-the-badge&label&logo=discord&logoColor=white&color=5A65EA)](https://discord.gg/k8s-at-home)
[![Renovate](https://img.shields.io/badge/Renovate-193B87?style=for-the-badge&logo=renovate&logoColor=white)](https://www.mend.io/renovate/)
[![Forgejo](https://img.shields.io/badge/Forgejo-EC622A?style=for-the-badge&logo=forgejo&logoColor=white)](https://forgejo.org)

_hcloud cluster stats:_

[![Talos](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/talos_version&style=for-the-badge&logo=talos&logoColor=white&color=D14459&label=%20)](https://talos.dev)
[![Kubernetes](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/kubernetes_version&style=for-the-badge&logo=kubernetes&logoColor=white&color=416BDD&label=%20)](https://kubernetes.io)
[![Flux](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/flux_version&style=for-the-badge&logo=flux&logoColor=white&color=416BDD&label=%20)](https://fluxcd.io)

![Age-Days](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/cluster_age_days&style=flat-square&label=Age)
![Uptime-Days](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/cluster_uptime_days&style=flat-square&label=Uptime)
![Node-Count](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/cluster_node_count&style=flat-square&label=Nodes)
![Pod-Count](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/cluster_pod_count&style=flat-square&label=Pods)
![CPU-Usage](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/cluster_cpu_usage&style=flat-square&label=CPU)
![Memory-Usage](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/cluster_memory_usage&style=flat-square&label=Memory)

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
2. [Create talos node on hcloud](setup/hcloud/opentofu/README.md)
3. [Bootstrap talos node](setup/hcloud/talos/README.md)
4. [Bootstrap k8s](clusters/hcloud/bootstrap/README.md)

### Directories
```bash
📁 clusters          # Kubernetes cluster
├ 📁 hcloud          # hetzner single node cluster
│  ├ 📁 apps         # apps sorted by namespaces
│  ├ 📁 bootstrap    #
│  ├ 📁 components   #
│  └ 📁 flux         #
├ 📁 home            # home single node cluster
│  ├ 📁 apps         # apps sorted by namespaces
│  ├ 📁 bootstrap    #
│  ├ 📁 components   #
│  └ 📁 flux         #
├ 📁 setup           # 
│  ├ 📁 hcloud       #
│  └ 📁 home         #
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
- [naoalb](https://code.onji.space/lab/k8s)
- [bjw-s](https://github.com/bjw-s-labs)
