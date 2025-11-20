# Authentik

## Secret key
Create random base64 string and used it as your authentik secret key

```bash
cat /dev/urandom | base64 | head -c 50
```
