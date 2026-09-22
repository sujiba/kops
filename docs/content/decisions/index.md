# Entscheidungen

Architecture Decision Records (ADRs) halten fest, **warum** etwas so gebaut ist. Ein ADR wird nach der Annahme nicht umgeschrieben: Ändert sich die Entscheidung, ersetzt ein neuer ADR den alten, und der alte bekommt den Status „ersetzt durch NNNN“.

| Nr. | Titel | Status |
|---|---|---|
| [0001](0001-docs-zensical-garage.md) | Doku mit Zensical und Garage | angenommen |

## Vorlage

Dateiname: `NNNN-kurztitel.md`, fortlaufend nummeriert. Danach in `docs/zensical.toml` unter `nav` eintragen.

```markdown
# NNNN Titel

| | |
|---|---|
| **Status** | vorgeschlagen / angenommen / ersetzt durch NNNN |
| **Datum** | JJJJ-MM-TT |

## Kontext

Welches Problem, welche Randbedingungen?

## Entscheidung

Was wir machen.

## Alternativen

| Option | Warum nicht |
|---|---|
| … | … |

## Konsequenzen

Was dadurch leichter, schwerer oder riskanter wird.
```
