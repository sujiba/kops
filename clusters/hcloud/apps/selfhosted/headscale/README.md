
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

# ACLs
```json

```