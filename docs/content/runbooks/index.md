# Runbooks

Jedes Runbook hat dieselbe Struktur: **Wann** (Auslöser), **Voraussetzungen**, **Schritte**, **Prüfen** und **Rollback**. So findest du unter Druck sofort den richtigen Abschnitt.

| Runbook | Wann |
|---|---|
| [Talos-Upgrade](talos-upgrade.md) | Neue Talos-Version, Renovate-PR für `siderolabs/talos` |
| [Doku-Bucket](docs-bucket.md) | Einmalig: Garage-Bucket für diese Doku einrichten |

!!! tip "Neues Runbook anlegen"

    1. Ein bestehendes Runbook in `docs/content/runbooks/` kopieren und umbenennen.
    2. Die Seite in `docs/zensical.toml` unter `nav` → `Runbooks` eintragen.
    3. Eine Zeile in der Tabelle oben ergänzen.
