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

2. Put the token into `kubernetes/home/apps/network/towonel-agent/app/secrets.sops.yaml` (`TOWONEL_INVITE_TOKEN`) and encrypt the file in place.

### Per hostname

The agent forwards all of `*.extern.${EXTERNAL_DOMAIN}` to `envoy-tunnel`, so a new hostname needs no change to the agent; only the app's route decides who answers.

1. Put the app under `kubernetes/home/apps/tunnel/` and list its `ks.yaml` in that directory's `kustomization.yaml`. `envoy-tunnel` accepts routes from the namespace `tunnel` only and reaches pods there only. The namespace enforces the Pod Security Standard `restricted` and has a quota, so the pods must run as non-root with `seccompProfile: RuntimeDefault`, `allowPrivilegeEscalation: false` and all capabilities dropped.

2. The app's HelmRelease: pod label, route on `envoy-tunnel` and a Cilium network policy that admits only `envoy-tunnel` and the host (replace `<name>` and the port). The example app [`hello`](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/home/apps/tunnel/hello/app/helmrelease.yaml) has all three:

    ```yaml
    defaultPodOptions:
      # envoy-tunnel may only reach pods with this label (network/towonel)
      labels:
        offene.cloud/expose: tunnel
    networkpolicies:
      app:
        type: cilium
        ingress:
          - fromEntities:
              - host # kubelet probes
          - fromEndpoints:
              - matchLabels:
                  k8s:io.kubernetes.pod.namespace: network
                  gateway.envoyproxy.io/owning-gateway-name: envoy-tunnel
            toPorts:
              - ports:
                  - port: "5678"
                    protocol: TCP
    route:
      app:
        hostnames:
          - <name>.extern.${EXTERNAL_DOMAIN}
        parentRefs:
          - name: envoy-tunnel
            namespace: network
            sectionName: https
    ```

    Exposed pods may reach cluster DNS only. If the app must call out (webhooks, federation, OIDC), add the label `offene.cloud/egress: internet` next to `offene.cloud/expose: tunnel`; egress to its own backends (database, cache) goes into its own network policy. `hello` needs neither.

3. Nothing changes on hcloud or in the agent: the TLSRoute already covers `*.extern.${EXTERNAL_DOMAIN}`.

## Verify

```bash
kubectl --kubeconfig ~/.kube/home -n network logs deploy/towonel-agent --tail 20
curl -s https://hello.extern.${EXTERNAL_DOMAIN}
kubectl --kubeconfig ~/.kube/home -n network logs deploy/envoy-tunnel -c envoy --tail 5 | grep hello
```

`curl` must print the example's text, and `downstream_remote_address` in the access log of `envoy-tunnel` must show your public address. A cluster or hcloud address means the PROXY chain is broken somewhere, and with it the geo block at home.

## Rollback

Remove the route from the app. `envoy-tunnel` then answers the hostname with 404.
