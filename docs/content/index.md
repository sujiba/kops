---
icon: lucide/house
hide:
  - navigation
---

# Home-Ops

Operations handbook for the Kubernetes clusters `hcloud` and `home`. Pick by situation:

<div class="grid cards" markdown>

-   :lucide-user-cog:{ .lg .middle } **Hands-on work**

    ---

    Step-by-step guides for bootstraps, upgrades and one-time setups.

    [:lucide-arrow-right: How-Tos](how-to/index.md)

-   :lucide-notebook-pen:{ .lg .middle } **Have we seen this before?**

    ---

    Dated incident logs with cause and fix.

    [:lucide-arrow-right: Incidents](incidents/index.md)

-   :lucide-book-open:{ .lg .middle } **How is X set up?**

    ---

    Building blocks like databases and backups: where they are configured and which knobs matter.

    [:lucide-arrow-right: Reference](reference/index.md)

-   :lucide-network:{ .lg .middle } **How does it fit together?**

    ---

    Diagrams of the GitOps flow and the docs pipeline.

    [:lucide-arrow-right: Architecture](architecture/index.md)

-   :lucide-scale:{ .lg .middle } **Why is it built this way?**

    ---

    Architecture decision records (ADRs) with context and alternatives.

    [:lucide-arrow-right: Decisions](decisions/index.md)

</div>

## :lucide-cpu: Hardware

Two single-node clusters: one in the Hetzner Cloud, one at home. Both nodes are control planes that also run workloads.

| Node | Cluster | OS | Hardware | Specs | Storage |
|:--|:--|:--|:--|:--|:--|
| **talos** | `hcloud` | Talos Linux | Hetzner Cloud CX43, Falkenstein | 8 vCPU / 16 GB | 160 GB SSD |
| **home-01** | `home` | Talos Linux | ASUS NUC, Intel Core Ultra 5 225H, Arc 130T iGPU | 14C / 14T / 48 GB | 512 GB NVMe (system) + 2 TB WD_BLACK SN770 (miroir), media via NFS |

## :lucide-puzzle: Core components

| Component | Description | Namespace |
|:--|:--|:--|
| **[Flux](https://fluxcd.io/)** | GitOps via flux-operator: syncs this repo into the cluster | `flux-system` |
| **[SOPS](https://getsops.io/)** + age | Secrets encrypted in Git, decrypted by Flux | – |
| **[Cilium](https://cilium.io/)** | CNI with kube-proxy replacement | `kube-system` |
| **[Envoy Gateway](https://gateway.envoyproxy.io/)** | Gateway API ingress, `envoy-internal` and `envoy-external` | `network` |
| **[cert-manager](https://cert-manager.io/)** | Let's Encrypt certificates | `cert-manager` |
| **[tuppr](https://github.com/home-operations/tuppr)** | Talos and Kubernetes upgrades via CRDs | `system-upgrade` |
| **[CloudNativePG](https://cloudnative-pg.io/)** | PostgreSQL clusters | `databases` |
| **[Dragonfly](https://www.dragonflydb.io/)** | Redis-compatible in-memory store | `databases` |
| **[miroir](https://miroir.home-operations.com/)** | Local volumes on the second NVMe, with snapshots | `miroir-system` |
| **[kopiur](https://kopiur.home-operations.com/)** + [Kopia](https://kopia.io/) | PVC backups and restores | `kopiur-system` |
| **[Garage](https://garagehq.deuxfleurs.fr/)** | S3 object storage and static websites (these docs) | `garage-system` |
| **[Pocket ID](https://pocket-id.org/)** | OIDC single sign-on with passkeys | `security` |
| **[Renovate](https://docs.renovatebot.com/)** | Dependency updates as pull requests | `renovate` |

## :lucide-layout-grid: Services

| Category | Applications |
|:--|:--|
| **Media** | [Jellyfin](https://jellyfin.org/), [Immich](https://immich.app/), [Calibre-Web Automated](https://github.com/crocodilestick/Calibre-Web-Automated) |
| **Downloads** | [Sonarr](https://sonarr.tv/), [Radarr](https://radarr.video/), [Prowlarr](https://prowlarr.com/), [SABnzbd](https://sabnzbd.org/) |
| **Home automation** | [Home Assistant](https://www.home-assistant.io/), [Zigbee2MQTT](https://www.zigbee2mqtt.io/), [Mosquitto](https://mosquitto.org/) |
| **Documents & tools** | [Nextcloud](https://nextcloud.com/), [Tandoor](https://tandoor.dev/), [FreshRSS](https://freshrss.org/), [Endurain](https://codeberg.org/endurain-project/endurain), [BentoPDF](https://github.com/alam00000/bentopdf), [IT-Tools](https://it-tools.tech/), [Paperless-ngx](https://docs.paperless-ngx.com/), [Vaultwarden](https://github.com/dani-garcia/vaultwarden) |
| **Communication** | [Matrix](https://matrix.org/) (Element Server Suite), [ntfy](https://ntfy.sh/), [MollySocket](https://github.com/mollyim/mollysocket) |
| **Development & AI** | [Forgejo](https://forgejo.org/), [LiteLLM](https://www.litellm.ai/) |
| **Network** | [Headscale](https://headscale.net/), [Tailscale](https://tailscale.com/), [Pi-hole](https://pi-hole.net/), SMTP relay |
| **Observability** | [Prometheus](https://prometheus.io/), [Grafana](https://grafana.com/), [Kromgo](https://github.com/kashalls/kromgo), [VictoriaLogs](https://docs.victoriametrics.com/victorialogs/), [Gatus](https://gatus.io/) |
| **Web** | [Zensical](https://zensical.org/) (these docs) |
