# Custom Keys
By default, Pocket ID generates a RSA-2048 private key upon first startup, which is used to sign all tokens. You can optionally use a key with a different RSA key size (e.g. 3072 or 4096), or even a different algorithm (e.g. ECDSA with P-256, or EdDSA with Ed25519). Further [info](https://pocket-id.org/docs/advanced/custom-keys).

```bash
kubectl --kubeconfig ~/.kube/hcloud -n security exec -it <pod-name> -- pocket-id key-rotate -a EdDSA -c Ed25519

# INFO Connected to database provider=sqlite
# WARNING: Rotating the private key will invalidate all existing tokens. Both pocket-id and all client applications will likely need to be restarted.
Confirm [y/N]: y
# Key rotated successfully
# Note: if pocket-id is running, you will need to restart it for the new key to be loaded
```

# Setup
You can now sign in with the admin account on `https://<your-app-url>/setup`.
