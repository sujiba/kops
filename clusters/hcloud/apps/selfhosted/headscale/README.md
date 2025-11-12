
# headscale api key

Generate a headscale api key to authenticate yourself with headplan against the headscale api:

```bash
# Create api key. Defaults to 90 days until expiration
kubectl -n <namespace> exec <podname> -- headscale apikeys create

# list all api keys
kubectl -n <namespace> exec <podname> -- headscale apikeys list
ID | Prefix | Expiration | Created

# expire api key
kubectl -n <namespace> exec <podname> -- headscale apikeys expire --prefix "key_prefix"

# delete api key
kubectl -n <namespace> exec <podname> -- headscale apikeys delete --prefix "Wl6E9yL"
```

# Add users

# Add nodes

# Add tags to nodes
```bash
# set tags on nodes
kubectl -n <namesapce> exec <podname> -- headscale nodes tag -i <node_id> -t tag:<name>,tag:<name2>

# list nodes with their tags
kubectl -n <namesapce> exec <podname> -- headscale nodes list -t
```

# ACLs
```json

```
