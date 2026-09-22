# 0001 Doku mit Zensical und Garage

| | |
|---|---|
| **Status** | angenommen |
| **Datum** | 2026-09-22 |

## Kontext

Betriebswissen (Runbooks, Störungen, Entscheidungen) lag verstreut in READMEs. Gebraucht wird eine durchsuchbare Doku direkt im Infra-Repo, ohne zusätzliche Toolchain und selbst gehostet.

## Entscheidung

- **Generator:** [Zensical](https://zensical.org/), Nachfolger von Material for MkDocs, Konfiguration in `docs/zensical.toml`.
- **Hosting:** Garage-Bucket `docs.offene.cloud` im Website-Modus, ausgeliefert über `envoy-external`.
- **Deploy:** CI-Job auf dem `forgejo-runner` im Cluster, Upload per `aws s3 sync --delete`.

## Alternativen

| Option | Warum nicht |
|---|---|
| MkDocs + Material | Unklare Zukunft |
| Starlight / Docusaurus | Bringt eine Node-Toolchain ins Infra-Repo |
| mdBook | Zu wenig Doku-Features (Admonitions, Tabs, Cards) |
| GitHub Pages | Später als Zweitziel denkbar, bräuchte einen Mirror nach GitHub |

## Konsequenzen

!!! warning "Zensical ist vor 0.1"

    Breaking Changes sind möglich. Fallback: ProperDocs mit Material, die Markdown-Inhalte bleiben kompatibel.

- **Keine Redirects:** Garage kann nicht umleiten. Links zeigen immer auf Directory-URLs (`pfad/`), umbenannte Seiten erzeugen tote Links.
- **Doku ist weg, wenn der Cluster `hcloud` down ist.** Für Notfälle die Markdown-Dateien direkt im Repo lesen.
- **GeoIP-Policy** am Gateway `envoy-external` gilt auch für die Doku.
