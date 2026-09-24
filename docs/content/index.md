---
hide:
  - toc
---

# Home-Ops

Operations handbook for the Kubernetes clusters `hcloud` and `home`. Pick by situation:

<div class="grid cards" markdown>

-   :lucide-siren:{ .lg .middle } **Something is broken**

    ---

    Step-by-step guides for recurring tasks.

    [:lucide-arrow-right: Runbooks](runbooks/index.md)

-   :lucide-book-open:{ .lg .middle } **How is X set up?**

    ---

    Building blocks like databases and backups: where they are configured and which knobs matter.

    [:lucide-arrow-right: Reference](reference/index.md)

-   :lucide-history:{ .lg .middle } **Have we seen this before?**

    ---

    Dated incident logs with cause and fix.

    [:lucide-arrow-right: Troubleshooting](troubleshooting/index.md)

-   :lucide-network:{ .lg .middle } **How does it fit together?**

    ---

    Diagrams of the GitOps flow and the docs pipeline.

    [:lucide-arrow-right: Architecture](architecture/index.md)

-   :lucide-scale:{ .lg .middle } **Why is it built this way?**

    ---

    Architecture decision records (ADRs) with context and alternatives.

    [:lucide-arrow-right: Decisions](decisions/index.md)

</div>

## At a glance

| | |
|---|---|
| OS | [Talos Linux](https://www.talos.dev/) |
| GitOps tool | [Flux](https://fluxcd.io/) via flux-operator |
| Nodes | `talos` (cluster `hcloud`, Hetzner Cloud) · `home-01` (cluster `home`, ASUS NUC) |
| Object storage | [Garage](https://garagehq.deuxfleurs.fr/) via garage-operator (cluster `hcloud`) |
| Repo | [homelab/kops](https://code.offene.cloud/homelab/kops) |
