<div align="center">

# My Home Operations Repository <!-- omit in toc -->

_... managed by FluxCD, Renovate, and Forgejo Actions_ 🤖

[![Discord](https://img.shields.io/discord/673534664354430999?style=for-the-badge&label&logo=discord&logoColor=white&color=blue)](https://discord.gg/k8s-at-home)
[![Renovate](https://img.shields.io/badge/powered_by-Renovate-blue?style=for-the-badge&logo=renovate)](https://www.mend.io/renovate/)


Kubernetes cluster stats:

[![Age-Days](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/cluster_age_days&style=flat-square&label=Age)](https://github.com/kashalls/kromgo)
[![Uptime-Days](https://img.shields.io/endpoint?url=https://kromgo.offene.cloud/Fcluster_uptime_days&style=flat-square&label=Uptime)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;

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

## 🔧 Hardware

## 🤝 Special thanks
- [Home Operations discord community](https://discord.gg/home-operations)
- [kubesearch.dev](https://kubesearch.dev/)
- [naoalb](https://code.onji.space/lab/k8s-cluster)
- [bjw-s](https://github.com/bjw-s-labs)
