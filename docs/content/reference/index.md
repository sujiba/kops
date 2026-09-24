---
icon: lucide/book-open
---

# Reference

Reference pages describe the building blocks of the clusters: what exists, where it is configured, which knobs matter and what it creates. The manifests under [`kubernetes/`](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes) stay the source of truth; these pages explain their structure and link to them. Only shared building blocks get a page; a single app's `helmrelease.yaml` is its own reference. Why this section exists: [ADR 0002](../decisions/0002-diataxis.md).

| Reference | Cluster | Covers |
|---|---|---|
| | | |

## Template

File name: `short-title.md`. Then add it to `nav` → `Reference` in `docs/zensical.toml` and add a row to the table above.

```markdown
# Title

| | |
|---|---|
| **What** | One sentence: what it is and what it is used for |
| **Cluster** | hcloud / home / both |
| **Manifests** | [kubernetes/<cluster>/…](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/<cluster>/…) |

## Configuration

| Knob | Default | Meaning |
|---|---|---|
| … | … | … |

## Creates

| Resource | Name | Purpose |
|---|---|---|
| … | … | … |

## Related

- Runbooks, ADRs and other reference pages that use it.
```

!!! warning "No volatile values"

    Versions, image tags and resource limits go stale. Name the knob and link the manifest instead of copying its value.
