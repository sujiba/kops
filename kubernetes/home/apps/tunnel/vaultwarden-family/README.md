# vaultwarden-family

Family instance, public as `vault.extern.${EXTERNAL_DOMAIN}` through the towonel tunnel. Separate from the personal instance `vaultwarden` (LAN only).

## Admin token
Create the hash in a temporary container and put it into `app/secrets.sops.yaml` as `ADMIN_TOKEN`, then encrypt the file in place:

```bash
kubectl run -it --rm temp --image=ghcr.io/dani-garcia/vaultwarden -- /vaultwarden hash
```

## Admin page
`/admin` is blocked on the public route. Forward the service and open http://localhost:8080/admin:

```bash
kubectl -n tunnel port-forward svc/vaultwarden-family 8080:80
```

## Invite family members
Signups and organization invitations are off. Invite each member from the admin page (Users → Invite User); the mail goes out through the smtp-relay. Then create an organization for the family and enable the policy "Require two-step login".
