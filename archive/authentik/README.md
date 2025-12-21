# Authentik

## Secret key
Create random base64 string and used it as your authentik secret key

```bash
cat /dev/urandom | base64 | head -c 50
```

## Admin account
If you're not redirected to the inital setup flow, try to open it directly:

`https://your.authentik.domain/if/flow/initial-setup/`

If this doesn't work you can force create an admin account through this command:

```bash
kubectl --kubeconfig ~/.kube/hcloud  -n security exec -it <server_pod_name> -- ak changepassword authmin
```

### Change admin username

You could change the default username of the administrator account to something else:

`https://your.authentik.domain/if/admin/#/identity/users`


## Settings
### Test mail settings

```bash
kubectl --kubeconfig ~/.kube/hcloud  -n security exec -it <worker_pod_name> -- ak test_email your_mail_address
```

### Create users
`https://auth.offene.cloud/if/admin/#/identity/users`

### Disable Gravatar

Remove gravatar from avatar settings.

`https://your.authentik.domain/if/admin/#/admin/settings`

## Integrations

If you want to add OIDC to an application you can take a look at authentiks [integrations docs](https://integrations.goauthentik.io/).
