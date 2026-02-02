# Create vaultwarden admin
Enable admin page and create token via a temporary container

```bash
# Start temporary vaultwarden container
kubectl run -it --rm temp --image=ghcr.io/dani-garcia/vaultwarden -- bash

# create your password hash
/vaultwarden hash

# Copy the output into your secret.sops.yaml 
ADMIN_TOKEN='$argon2id$v=19$m=65540,t=3,p=4$OsCnPeQK3NTYCg8Jk0fx7x6DQISS++Pf8MuEOX2v6+g$y8QO+q41e1H7Ms/2ZpO7cWajZ7oCqOqoaVy4OFKeLqE'

# and replace <=> with <:>
ADMIN_TOKEN: '$argon2id$v=19$m=65540,t=3,p=4$OsCnPeQK3NTYCg8Jk0fx7x6DQISS++Pf8MuEOX2v6+g$y8QO+q41e1H7Ms/2ZpO7cWajZ7oCqOqoaVy4OFKeLqE'

# exit container
<ctrl-d>
```
