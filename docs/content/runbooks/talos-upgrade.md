# Talos-Upgrade

| | |
|---|---|
| **Wann** | Neue Talos-Version verfügbar, Renovate hat einen PR für `siderolabs/talos` geöffnet |
| **Dauer** | ca. 10–15 Minuten pro Node |
| **Risiko** | Mittel: beide Cluster sind Single-Node, der Cluster ist während des Reboots nicht erreichbar |

## Voraussetzungen

- [ ] Changelog der Zielversion gelesen (Breaking Changes, Kubernetes-Kompatibilität)
- [ ] `talosctl` lokal auf Zielversion oder neuer
- [ ] `talosconfig` und `kubeconfig` für den Cluster vorhanden
- [ ] Aktuelle Backups (kopiur) erfolgreich gelaufen
- [ ] Kein anderer Eingriff am Cluster läuft

!!! warning "Immer nur ein Node gleichzeitig"

    Nie mehrere Nodes parallel upgraden. Bei unseren Single-Node-Clustern heißt das außerdem: Jedes Upgrade bedeutet Downtime für alle Dienste des Clusters.

## Schritte

Die Version steht an mehreren Stellen und wird von Renovate gemeinsam aktualisiert. Standardweg ist tuppr, die manuellen Wege sind der Fallback.

=== "tuppr (Standard)"

    1. Renovate-PR prüfen. Er ändert die Version in
        - `kubernetes/<cluster>/apps/system-upgrade/tuppr/upgrades/talos.yaml`
        - `kubernetes/bootstrap/hcloud/2_talos/talconfig.yaml` bzw. `kubernetes/bootstrap/home/2_talos/topf.yaml`
    2. PR mergen. Flux wendet das `TalosUpgrade` an, tuppr führt das Upgrade aus.
    3. Fortschritt verfolgen:

        ```bash
        kubectl get talosupgrade -A -w
        ```

=== "hcloud (talhelper)"

    ```bash
    cd kubernetes/bootstrap/hcloud/2_talos
    talhelper genconfig
    talhelper gencommand upgrade --extra-flags "--preserve" | sh
    ```

=== "home (topf)"

    ```bash
    cd kubernetes/bootstrap/home/2_talos
    topf render   # Änderungen offline prüfen
    topf upgrade
    ```

## Prüfen

```bash
talosctl version -n <node-ip>
talosctl etcd status -n <node-ip>
kubectl get nodes -o wide
```

Die Node muss `Ready` sein, Server-Version muss der Zielversion entsprechen.

## Rollback

```bash
talosctl rollback -n <node-ip>
```

Danach die Version in den oben genannten Dateien zurücksetzen, sonst startet tuppr das Upgrade erneut.

??? note "Hintergrund: Wie Talos upgradet"

    Talos hat zwei Boot-Partitionen (A/B). Ein Upgrade schreibt das neue Image in die inaktive Partition und bootet daraus. `talosctl rollback` schaltet einfach wieder auf die vorherige Partition um. Deshalb ist ein Rollback schnell, funktioniert aber nur einmal zurück.

    tuppr ist ein Controller, der `TalosUpgrade`- und `KubernetesUpgrade`-Ressourcen ausführt. So bleibt das Upgrade GitOps-gesteuert und läuft nicht von einem Laptop aus.
