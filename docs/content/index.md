---
hide:
  - toc
---

# Home-Ops

Betriebshandbuch für die Kubernetes-Cluster `hcloud` und `home`. Wähle nach Situation:

<div class="grid cards" markdown>

-   :lucide-siren:{ .lg .middle } **Etwas ist kaputt**

    ---

    Schritt-für-Schritt-Anleitungen für wiederkehrende Eingriffe.

    [:lucide-arrow-right: Runbooks](runbooks/index.md)

-   :lucide-history:{ .lg .middle } **Hatten wir das schon mal?**

    ---

    Datierte Störungsprotokolle mit Ursache und Lösung.

    [:lucide-arrow-right: Troubleshooting](troubleshooting/index.md)

-   :lucide-network:{ .lg .middle } **Wie hängt das zusammen?**

    ---

    Diagramme zu GitOps-Fluss und Doku-Pipeline.

    [:lucide-arrow-right: Architektur](architecture/index.md)

-   :lucide-scale:{ .lg .middle } **Warum ist das so?**

    ---

    Architekturentscheidungen (ADRs) mit Kontext und Alternativen.

    [:lucide-arrow-right: Entscheidungen](decisions/index.md)

</div>

## Auf einen Blick

| | |
|---|---|
| OS | [Talos Linux](https://www.talos.dev/) |
| GitOps-Tool | [Flux](https://fluxcd.io/) über flux-operator |
| Nodes | `talos` (Cluster `hcloud`, Hetzner Cloud) · `home-01` (Cluster `home`, ASUS NUC) |
| Object Storage | [Garage](https://garagehq.deuxfleurs.fr/) über garage-operator (Cluster `hcloud`) |
| Repo | [homelab/kops](https://code.offene.cloud/homelab/kops) |
