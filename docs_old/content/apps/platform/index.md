---
title: platform
description: Cluster, network and storage machinery.
---

# platform

Machinery the clusters need to run: CNI, ingress, operators, backup, DNS and VPN. These apps exist so everything else works, even when some of them have a web UI.

## Applications

| App | Namespace | Cluster(s) | Description |
| --- | --- | --- | --- |
| [kopiur](kopiur.md) | `kopiur-system` | `home` | Kopia-based backup operator for PVCs |

<!-- TODO: Document the remaining platform apps: cilium, envoy-gateway, miroir, cert-manager, cert-manager-webhook-netcup, flux-instance, flux-operator, konflate, cloudnative-pg, dragonfly, dragonfly-operator, pihole, smtp-relay, tailscale, headscale, kopia, intel-gpu-resource-driver, k8tz, metrics-server, reloader, snapshot-controller, openebs, garage, garage-operator, garage-ui, renovate-operator, tuppr, litellm-operator, mosquitto, media-nfs. -->
