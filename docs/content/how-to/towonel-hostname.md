---
icon: lucide/cable
---

# Expose a home app through the tunnel

| | |
|---|---|
| **When** | A home app should be public as `<name>.extern.${EXTERNAL_DOMAIN}` via [towonel](../reference/towonel.md). The first section applies once, when the agent joins the hub |
| **Duration** | about 15 minutes |
| **Risk** | Medium: the app becomes reachable from the internet |

## Prerequisites

- [ ] `kubectl` access to both clusters (`~/.kube/hcloud`, `~/.kube/home`)
- [ ] DNS: `*.extern.${EXTERNAL_DOMAIN}` and `tunnel.${EXTERNAL_DOMAIN}` resolve to hcloud
- [ ] UDP 51820 open on the hcloud firewall (`kubernetes/bootstrap/hcloud/1_tofu/main.tf`, applied with tofu)

## Steps

### Once: join the agent

1. Create an invite on the hub. The operator key is generated on first boot and only lives on the hub's volume:

    ```bash
    kubectl --kubeconfig ~/.kube/hcloud -n network exec -it deploy/towonel -- \
      sh -c 'towonel invite create --name home --hostnames "*.extern.${EXTERNAL_DOMAIN}" \
        --hub-url http://localhost:8443 --api-key "$(cat /data/operator.key)"'
    ```

    Replace `${EXTERNAL_DOMAIN}` with the real domain.

2. Put the token into `kubernetes/home/apps/network/towonel/agent/secrets.sops.yaml` (`TOWONEL_INVITE_TOKEN`) and encrypt the file in place.

### Per hostname

1. `kubernetes/home/apps/network/towonel/agent/helmrelease.yaml`: add an entry to `TOWONEL_AGENT_SERVICES` with origin `envoy-tunnel.network.svc.cluster.local:443`, `tls_mode` passthrough and `proxy_protocol` `v2` (copy the `whoami` entry).
2. The app's HelmRelease: route with parent `envoy-tunnel` (`sectionName: https`), hostname `<name>.extern.${EXTERNAL_DOMAIN}`, pod label `offene.cloud/expose: tunnel`, and a Cilium network policy that admits only `envoy-external` and the host. Copy all three from `kubernetes/home/apps/selfhosted/whoami/app/helmrelease.yaml`.
3. Nothing changes on hcloud: the TLSRoute already covers `*.extern.${EXTERNAL_DOMAIN}`.

## Verify

```bash
kubectl --kubeconfig ~/.kube/home -n network logs deploy/towonel-agent --tail 20
curl -s https://whoami.extern.${EXTERNAL_DOMAIN}
```

The whoami response must show your public address in `X-Real-Ip`. A cluster or hcloud address means the PROXY chain is broken somewhere, and with it the geo block at home.

## Rollback

Remove the entry from `TOWONEL_AGENT_SERVICES` and the route from the app. The edge drops connections for hostnames no agent serves.
