<div align="center">

# K(ubernetes) Op(eration)s <!-- omit in toc -->

### 🏠 A GitOps-managed Homelab <!-- omit in toc -->

_... powered by [Talos](https://www.siderolabs.com/talos-linux), [Flux](https://fluxcd.io/) and [Kubernetes](https://kubernetes.io/)_

[![Talos](https://kromgo.offene.cloud/badges/talos_version)](https://talos.dev)
[![Kubernetes](https://kromgo.offene.cloud/badges/kubernetes_version)](https://kubernetes.io)
[![Flux](https://kromgo.offene.cloud/badges/flux_version)](https://fluxcd.io)


![Age](https://kromgo.offene.cloud/badges/cluster_birth_age)
![Uptime](https://kromgo.offene.cloud/badges/cluster_uptime_age)
![Nodes](https://kromgo.offene.cloud/badges/cluster_node_count)
![Pods](https://kromgo.offene.cloud/badges/cluster_pod_count)
![CPU](https://kromgo.offene.cloud/badges/cluster_cpu_usage)
![Memory](https://kromgo.offene.cloud/badges/cluster_memory_usage)

</div>


## 📖 Overview
- [📖 Overview](#-overview)
- [📚 Docs](#-docs)
- [⛵ Kubernetes](#-kubernetes)
  - [Installation](#installation)
  - [Directories](#directories)
  - [Networking](#networking)
- [☁ Cloud Dependencies](#-cloud-dependencies)
- [🔧 Hardware](#-hardware)
- [🤝 Special thanks](#-special-thanks)

## 📚 Docs
The operations handbook lives in [`docs/`](docs/content/index.md) and is published at [docs.offene.cloud](https://docs.offene.cloud/): how-tos, reference pages, architecture diagrams, decision records (ADRs) and incident logs.

## ⛵ Kubernetes
Two single-node clusters, each with its own Flux instance syncing `kubernetes/<cluster>/flux`:

- `hcloud`: Hetzner Cloud
- `home`: at home

### Installation
1. `git clone https://code.offene.cloud/homelab/kops.git`
2. `hcloud`
   1. [Create talos node on hcloud](kubernetes/bootstrap/hcloud/1_tofu/README.md)
   2. [Bootstrap talos node (topf)](kubernetes/bootstrap/hcloud/2_talos/README.md)
   3. [Bootstrap k8s](kubernetes/bootstrap/hcloud/3_flux/README.md)
3. `home`
   1. [Bootstrap talos node (topf)](kubernetes/bootstrap/home/2_talos/README.md)
   2. [Bootstrap k8s](kubernetes/bootstrap/home/3_flux/README.md)

See also the how-tos [Talos bootstrap](docs/content/how-to/talos-bootstrap.md) and [Flux bootstrap](docs/content/how-to/flux-bootstrap.md).

### Directories
```bash
📁 kops
├─📁 .agents              # AI agent instructions and skills
├─📁 archive              # retired apps
├─📁 docs                 # Zensical operations handbook
└─📁 kubernetes
   ├─📁 bootstrap
   │  ├─📁 hcloud         # 1_tofu, 2_talos (topf), 3_flux
   │  └─📁 home           # 2_talos (topf), 3_flux
   ├─📁 hcloud            # single node cluster (Hetzner Cloud)
   │  ├─📁 apps           # applications
   │  ├─📁 components     # reusable kustomize components
   │  └─📁 flux
   └─📁 home              # single node cluster (at home)
      ├─📁 apps           # applications
      ├─📁 components     # reusable kustomize components
      └─📁 flux
```

### Networking

| Component                                           | Use                                                       |
|-----------------------------------------------------|-----------------------------------------------------------|
| [Cilium](https://cilium.io/)                        | CNI with kube-proxy replacement                           |
| [Envoy Gateway](https://gateway.envoyproxy.io/)     | Gateway API ingress (`envoy-internal`, `envoy-external`)  |
| [cert-manager](https://cert-manager.io/)            | Let's Encrypt certificates                                |
| [Headscale](https://headscale.net/) / [Tailscale](https://tailscale.com/) | Mesh VPN                            |
| [Pi-hole](https://pi-hole.net/)                     | DNS                                                       |

All components and apps are listed in the [handbook](docs/content/index.md).

## ☁ Cloud Dependencies

| Service | Use                                     | Cost    |
|---------|-----------------------------------------|---------|
| Netcup  | DNS                                     | ~80€/yr |
| Hetzner | Cloud Server CX43 (`hcloud`) / Backup   | ~35€/mo |

## 🔧 Hardware

| Device                    | Cluster  | Specs             | Storage                                               | OS    | Function        |
|---------------------------|----------|-------------------|-------------------------------------------------------|-------|-----------------|
| Hetzner Cloud CX43        | `hcloud` | 8 vCPU / 16 GB    | 160 GB SSD                                            | Talos | Kubernetes      |
| ASUS NUC 15 Pro CU 5 225H | `home`   | 14C / 14T / 96 GB | 512 GB NVMe (system) + 2 TB WD_BLACK SN770 (miroir)   | Talos | Kubernetes      |
| Synology RS1221+          | –        | 4 GB              | 7x12TB btrfs (SHR-2)                                  | DSM   | NFS (media)     |

## 🤝 Special thanks
Huge thanks to [@onedr0p](https://github.com/onedr0p), [@bjw-s](https://github.com/bjw-s-labs), [@eleboucher](https://github.com/eleboucher) and the [Home Operations Discord community](https://discord.gg/home-operations) for their knowledge and support. If you're looking for inspiration, check out [kubesearch.dev](https://kubesearch.dev/) to discover how others are deploying applications in their homelabs. Thanks also to [naoalb](https://code.offene.cloud/lab/k8s) for sharing their setup.
