


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