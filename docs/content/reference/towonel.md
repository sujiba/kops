---
icon: lucide/cable
---

# towonel

| | |
|---|---|
| **What** | Tunnel from hcloud to home: public hostnames below `extern.${EXTERNAL_DOMAIN}` are served from the homelab without opening ports there. TLS is passed through and ends at home |
| **Cluster** | both: hub and edge on hcloud, agent on home |
| **Manifests** | [hcloud/apps/network/towonel](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/hcloud/apps/network/towonel), [home/apps/network/towonel-agent](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/home/apps/network/towonel-agent), [home envoy-tunnel](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/home/apps/network/envoy-gateway/config/tunnel) |

## The path of a request

```text
visitor ─TLS─▶ envoy-external (hcloud) :443 (listener tunnel, SNI *.extern, PROXY v2) ─▶ towonel edge
        ─QUIC :51820─▶ towonel-agent (home) ─PROXY v2─▶ envoy-tunnel (home) ─▶ app
```

hcloud never decrypts the stream. The visitor's address survives every hop: Envoy on hcloud prepends PROXY v2, the edge reads it (`TOWONEL_EDGE_PROXY_PROTOCOL`), the agent prepends it again, and `envoy-tunnel` refuses connections without the header (`proxyProtocol.optional: false`).

## Configuration

| Knob | Where | Meaning |
|---|---|---|
| Listener `tunnel` | hcloud `envoy-gateway/config/gateway.yaml` | TLS passthrough for `*.extern.${EXTERNAL_DOMAIN}`; the more specific SNI wins over the catch-all `https` listener |
| Listener `towonel-quic` | same | UDP 51820 for the agent's QUIC, routed to the pod by the UDPRoute |
| Firewall rule `towonel quic` | `kubernetes/bootstrap/hcloud/1_tofu/main.tf` | UDP 51820 open on the Hetzner cloud firewall |
| `TOWONEL_HUB_PUBLIC_URL`, `TOWONEL_EDGE_ADVERTISED_ADDRESSES` | hcloud `towonel/app/helmrelease.yaml` | `tunnel.${EXTERNAL_DOMAIN}`: hub API and the edge address the agent dials |
| `TOWONEL_EDGE_PROXY_PROTOCOL_TRUSTED`, `TOWONEL_HUB_TRUSTED_PROXIES` | same | The node's cni0 address, the source of every connection from the host-network Envoy. Only it may send a PROXY header or `X-Forwarded-For`, so no pod can fake a client address. Follows the node's podCIDR |
| `agent.services` | home `towonel-agent/app/helmrelease.yaml` (upstream chart `towonel-agent`) | One wildcard entry `*.extern.${EXTERNAL_DOMAIN}` with origin `envoy-tunnel`; the routes on `envoy-tunnel` pick the app. The chart turns the list into `TOWONEL_AGENT_SERVICES` |
| Pod label `offene.cloud/expose: tunnel` | the app's HelmRelease | Lets `envoy-tunnel` reach the pod; also puts the pod under the egress policy `tunnel-workloads-egress` (cluster DNS only) |
| Pod label `offene.cloud/egress: internet` | the app's HelmRelease | Opt-in for exposed pods that must call out: adds the public IPv4 internet (`tunnel-workloads-internet`) |
| `geoip-policy-tunnel` | home `envoy-gateway/config/tunnel/securitypolicy.yaml` | Same country allowlist as `geoip-policy` on hcloud. Keep both in step |

## Creates

| Resource | Name | Purpose |
|---|---|---|
| HelmRelease (hcloud) | `towonel` | Hub and edge in one pod (app-template, not the upstream chart, see [#2425](https://code.offene.cloud/homelab/kops/issues/2425)); state on the PVC `towonel-data-pvc`. Also renders a ServiceMonitor |
| PrometheusRule, GrafanaDashboard (hcloud) | `towonel` | Hub alerts and the hub/edge dashboard, both taken from the upstream chart `towonel-node` |
| TLSRoute, UDPRoute (hcloud) | `towonel`, `towonel-quic` | Hand the passthrough TLS and the QUIC traffic to the pod |
| EnvoyPatchPolicy (hcloud) | `towonel-quic-gro` | Lets Envoy read coalesced UDP; without it the tunnel stalls on large packets |
| HelmRelease (home) | `towonel-agent` | Upstream chart; dials the edge and forwards each connection to `envoy-tunnel`. Also renders a ServiceMonitor, a PrometheusRule and a GrafanaDashboard |
| Gateway (home) | `envoy-tunnel` | ClusterIP only, no LAN address; certificate `tunnel-wildcard-tls` |
| CiliumNetworkPolicy, CiliumClusterwideNetworkPolicy (home) | `envoy-tunnel`, `towonel-agent-isolation`, `tunnel-workloads-egress`, `tunnel-workloads-internet` | Only the agent reaches `envoy-tunnel`, which reaches only opted-in pods; those reach neither the LAN, other workloads nor, without opt-in, the internet. The agent itself may reach only hcloud |

## Secrets

- hcloud `towonel-hub-secret`: `TOWONEL_HUB_KEK`, `TOWONEL_INVITE_HASH_KEY` (`TOWONEL_HUB_LINK_PSK` is unused since hub and edge share one pod)
- home `towonel-agent-secret`: `TOWONEL_INVITE_TOKEN`
- home `maxmind-secret`: `account_id`, `license_key` (geoipupdate sidecar of `envoy-tunnel`)

The hub state (SQLite, node and operator key) sits on `openebs-hostpath` without backup. Losing it means a new invite for the agent; the KEK and invite-hash key come from the Secret.

## Notes

??? note "Why a subdomain and not single hostnames"

    Browsers reuse an HTTP/2 connection for every hostname its certificate covers that resolves to the same address. hcloud's certificate covers `*.${EXTERNAL_DOMAIN}`, home's only `*.extern.${EXTERNAL_DOMAIN}`, and a wildcard covers exactly one label. So neither certificate covers the other's hostnames, no connection is pooled across the clusters, and both keep wildcard certificates. A hostname moves home by changing only the home side.

??? note "No HTTP/3 on hcloud"

    QUIC cannot be passed through by SNI, so an HTTP/3 request for a tunnelled hostname would end in hcloud's HTTP stack. `http3` is off in the hcloud ClientTrafficPolicy (UDP 443 was never open in the firewall anyway).

!!! warning "geoip-policy names the HTTP listeners"

    On a passthrough TLS or UDP listener the country rules become an empty RBAC matcher, and Envoy rejects the config of the whole Gateway while every status still says `Accepted`. `geoip-policy` therefore targets the `http` and `https` sections only.

## Related

- [Expose a home app through the tunnel](../how-to/towonel.md)
