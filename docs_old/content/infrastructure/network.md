---
title: network
description: Gateways, DNS and VPN for the kops clusters.
---

# network

How traffic reaches workloads in the `home` and `hcloud` clusters: Envoy Gateway with Gateway API, Pi-hole for DNS, and Tailscale/Headscale for VPN access.

## Ingress

Both clusters run [Envoy Gateway](https://gateway.envoyproxy.io/) in the `network` namespace and expose apps via Gateway API `HTTPRoute`s (usually through the app-template chart's `route:` value):

- `envoy-external` - publicly reachable apps, hostnames like `<app>.${EXTERNAL_DOMAIN}`
- `envoy-internal` - LAN-only apps, hostnames like `<app>.${INTERNAL_DOMAIN}`

Gateway definitions: [home](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/home/apps/network/envoy-gateway/config/gateway.yaml) · [hcloud](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/hcloud/apps/network/envoy-gateway/config/gateway.yaml). TLS certificates come from cert-manager (with a Netcup DNS webhook in the `home` cluster).

<!-- TODO: Describe listener/section layout (https, vpn) and IP assignment (${ENVOY_INTERNAL_IPv4/6}, ${ENVOY_VPN_IPv4/6}). -->

## DNS

Both clusters run Pi-hole in the `network` namespace as the private DNS resolver (`${PRIVATE_DNS_IPv4}` / `${PRIVATE_DNS_IPv6}`), providing ad blocking and resolution of the internal hostnames.

<!-- TODO: Document external DNS setup (Netcup) and how internal hostnames are resolved. -->

## Mail relay

Both clusters run an `smtp-relay` in the `network` namespace. Apps send their outbound mail (notifications, invitations) unauthenticated to `smtp-relay.network.svc.cluster.local` with sender addresses under `${MAIL_DOMAIN}`; the relay forwards it authenticated to the upstream SMTP server configured in its SOPS secret.

## VPN

Tailscale runs in the `network` namespace of both clusters; the `hcloud` cluster additionally hosts a self-hosted [Headscale](https://headscale.net/) control server (`selfhosted` namespace).

<!-- TODO: Describe the tailnet layout and which routes/subnets are advertised. -->
