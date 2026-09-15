---
title: apps
description: Per-app documentation for both kops clusters, grouped by function.
---

# apps

Documentation for the applications running in the `home` and `hcloud` clusters, grouped by what they are for - not by namespace. Each app page states its namespace and cluster(s), and one folder covers an app in every cluster that runs it.

## Groups

| Group | Content |
| --- | --- |
| [platform](platform/index.md) | Machinery the cluster, network and storage need to run: CNI, ingress, operators, backup, DNS, VPN |
| [observability](observability/index.md) | Monitoring, logging, dashboards, alerting and exporters |
| [services](services/index.md) | User-facing applications you open in a browser or client app |

The rule of thumb: if an app primarily exists so the cluster runs, it is `platform`; if it watches the cluster, it is `observability`; if it primarily exists for a person to use, it is `services`.
