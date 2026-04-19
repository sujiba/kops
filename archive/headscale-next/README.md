
# headscale api key

Generate a headscale api key to authenticate yourself with headplan against the headscale api:

```bash
# Create api key. Defaults to 90 days until expiration
kubectl --kubeconfig ~/.kube/hcloud \
   -n selfhosted exec headscale-0 \
   -- headscale apikeys create

# list all api keys
kubectl --kubeconfig ~/.kube/hcloud \
   -n selfhosted exec headscale-0 \
   -- headscale apikeys list

# ID | Prefix | Expiration | Created

# expire api key
kubectl --kubeconfig ~/.kube/hcloud \
   -n selfhosted exec headscale-0 \
   -- headscale apikeys expire --prefix "key_prefix"

# delete api key
kubectl --kubeconfig ~/.kube/hcloud \
   -n selfhosted exec headscale-0 \
   -- headscale apikeys delete --prefix "key_prefix"
```

# Add users
## OIDC setup with Pocket-ID
- Headscale [docs](https://github.com/juanfont/headscale/blob/main/config-example.yaml) to configure oidc.
- Pocket-ID [docs](https://pocket-id.org/docs/client-examples/headscale) to configure oidc.


# Add nodes

# Add tags to nodes
```bash
# set tags on nodes
kubectl --kubeconfig ~/.kube/hcloud \
   -n selfhosted exec headscale-0 \
   -- headscale nodes tag -i <node_id> -t tag:<name>,tag:<name2>

# list nodes with their tags
kubectl --kubeconfig ~/.kube/hcloud \
   -n selfhosted exec headscale-0 \
   -- headscale nodes list -t
```

# ACLs
```json

```
