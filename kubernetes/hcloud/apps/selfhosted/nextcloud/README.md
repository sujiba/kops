# Check if redis is working

Connect to redis / dragonfly pod and execute the following commands:
```bash
# Open the redis cli
redis-cli

# authenticate yourself
127.0.0.1:6379> auth <REDIS_SECRET>
Ok

# monitor redis traffic
127.0.0.1:6379> monitor
```

# OIDC setup with Pocket-ID

- Nextcloud Docs [docs](https://docs.nextcloud.com/server/stable/admin_manual/configuration_user/user_auth_oidc.html) to configure oidc.
- Pocket-ID [docs](https://pocket-id.org/docs/client-examples/nextcloud) to configure oidc.
