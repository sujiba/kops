# ntfy <!-- omit in toc -->

- [auth-users](#auth-users)
- [auth-access](#auth-access)
- [Adminhandbuch](#adminhandbuch)
  - [Topics](#topics)
  - [Permissions](#permissions)
  - [User and Roles](#user-and-roles)
  - [Access control list (ACL)](#access-control-list-acl)
  - [Beispiele](#beispiele)
    - [Commands](#commands)
    - [ACL](#acl)
  - [Access Tokens](#access-tokens)
- [Benutzerhandbuch](#benutzerhandbuch)
  - [Personal Access Tokens](#personal-access-tokens)
  - [Send notifications](#send-notifications)
    - [Example](#example)
    - [Cronjobs](#cronjobs)
    - [Low disk space alerts](#low-disk-space-alerts)
    - [SSH login alerts](#ssh-login-alerts)
    - [Ansible](#ansible)
    - [Forgejo Actions](#forgejo-actions)
    - [Home Assistant](#home-assistant)
    - [Jellyseerr](#jellyseerr)

# auth-users
You can set this as a secret:
```bash
# https://docs.ntfy.sh/config/#users-via-the-config
auth-users: '<username-1>:<password-hash>:<role>,<username-1>:<password-hash>:<role>'

# example:
auth-users: 'username:$2a$10$ciAnPNcWemcX6AEAgen5cOCsOoDrGmqfKeGx9Kj9IpM9TdSIdtF2:user'
```

# auth-access
You can set this as a secret:
```bash
# https://docs.ntfy.sh/config/#acl-entries-via-the-config
auth-access: '<username-1>:<topic-pattern-1>:<access>,<username-2>:<topic-pattern-2>:<access>'

#example
auth-access: '*:up*:wo,*:jellyfin:ro,username:username_*:rw,username:up*:ro,username:jellyfin:rw'
```

# Adminhandbuch    

<details>

Die Befehle werden im Container ausgeführt:

```bash
docker compose exec -it ntfy sh
```

## Topics

Ein `Topic` hat entweder einen spezifischen Namen (z.B. `mytopic` oder `phil_alerts`) oder es besteht aus einem wildcard Muster, das mehrer Topics abdecken kann (z.B. `alerts_*` or `phil_*`). Als wildcard Zeichen wird nur `*` unterstützt.

## Permissions

Zwischen den folgende `Permissions` wird unterschieden:

- `read-write` (alias: `rw`): Erlaubt es, Nachrichten an ein bestimmtes `Topic` zu verschicken. Zudem erlaubt es, das `Topic` zu abonieren und die enthaltenen Nachrichten zu lesen.
- `read-only` (aliases: `read`, `ro`): Erlaubt nur das abonieren und lesen des `Topic`.
- `write-only` (aliases: `write`, `wo`): Erlaubt nur, Nachrichten an ein bestimmtes `Topic` zu verschicken.
- `deny` (alias: `none`): Verbietet den Zugriff auf ein bestimmtes `Topic`.

## User and Roles

Der Befehl `ntfy user` ermöglicht es dir, User hinzuzufügen, zu entfernen und zu bearbeiten. Darüber hinaus kannst du neue Passwörter vergeben oder User zu Admins machen.

**Roles:**

- Die Rolle `user` (default): Benutzer mit dieser Rolle habe keine speziellen Berechtigungen. Zugang zu `Topics` kann über `ntfy access` verwaltet werden.
- Die Rolle `admin`: Benutzer mit dieser Rolle habe Schreib- und Leserechte auf alle `Topics`. Somit ist eine granulare Zugriffsverwaltung nicht notwendig.

```bash
ntfy user list                     # Shows list of users (alias: 'ntfy access')
ntfy user add phil                 # Add regular user phil  
ntfy user add --role=admin phil    # Add admin user phil
ntfy user del phil                 # Delete user phil
ntfy user change-pass phil         # Change password for user phil
ntfy user change-role phil admin   # Make user phil an admin
ntfy user change-tier phil pro     # Change phil's tier to "pro"
```

## Access control list (ACL)

ACLs verwalten den Zugriff für normale und anonyme (`everyone`/`*`) User auf die verschiedenen `Topics`. Jeder Eintrag repräsentiert die Zugriffsrechte eines Users auf bestimmte `Topics`.

```bash
ntfy access                            # Shows access control list (alias: 'ntfy user list')
ntfy access USERNAME                   # Shows access control entries for USERNAME
ntfy access USERNAME TOPIC PERMISSION  # Allow/deny access for USERNAME to TOPIC
```

## Beispiele

### Commands

```
ntfy access                        # Shows entire access control list
ntfy access phil                   # Shows access for user phil
ntfy access phil mytopic rw        # Allow read-write access to mytopic for user phil
ntfy access everyone mytopic rw    # Allow anonymous read-write access to mytopic
ntfy access everyone "up*" write   # Allow anonymous write-only access to topics "up..."
ntfy access --reset                # Reset entire access control list
ntfy access --reset phil           # Reset all access for user phil
ntfy access --reset phil mytopic   # Reset access for user phil and topic mytopic
```

### ACL

```bash
$ ntfy access
user phil (admin)
- read-write access to all topics (admin role)
user ben (user)
- read-write access to topic garagedoor
- read-write access to topic alerts*
- read-only access to topic furnace
user * (anonymous)
- read-only access to topic announcements
- read-only access to topic server-stats
- no access to any (other) topics (server config)
```

## Access Tokens

Neben Username / Passwort ermöglicht ntfy den Zugriff über Access Tokens. Somit kann beispielsweise für jeden Host ein eigener Token generiert werden. Access Tokens können von einem User über die Webseite erzeugt werden oder durch die folgenden Befehle auf der Konsole:

```bash
ntfy token list                      # Shows list of tokens for all users
ntfy token list phil                 # Shows list of tokens for user phil
ntfy token add phil                  # Create token for user phil which never expires
ntfy token add --expires=2d phil     # Create token for user phil which expires in 2 days
ntfy token remove phil tk_th2sxr...  # Delete token
```

<p class="callout info">Ein Access Token gibt vollen Zugriff auf einen Account. Eine feinere Unterscheidung der Zugriffsrechte ist derzeit nicht möglich.</p>

</details>


# Benutzerhandbuch

<details>

## Personal Access Tokens

Es wird empfohlen für jeden Host und jede Anwendung einen eigenen Access Token zu erstellen. Somit muss das Passwort nicht an verschiedenen stellen abgelegt werden. Zudem kannst du dem Host oder der Anwendung von zentralen Stelle aus die Berechtigungen entziehen. Für die leichte Nachvollziehbarkeit, solltest du den Hostnamen oder App-Namen als Bezeichnung wählen.

1. Melde dich auf der ntfy Webseite an.
2. Klicke auf Konto und scrolle zur Stelle Access-Tokens.
3. Klicke auf Access-Token erzeugen.
4. Gebe die Bezeichnung und die dauer der Gültigkeit an. 
    1. Bezeichnung: hostname
    2. Dauer: Token verfällt nie

## Send notifications

Im Folgenden werden verschiedene Möglichkeiten für den Versand von Push-Nachrichten beschrieben.

### Example

```bash
curl ntfy.sh \
  -d '{
    "topic": "mytopic",
    "message": "Disk space is low at 5.1 GB",
    "title": "Low disk space alert",
    "tags": ["warning","cd"],
    "priority": 4,
    "attach": "https://filesrv.lan/space.jpg",
    "filename": "diskspace.jpg",
    "click": "https://homecamera.lan/xasds1h2xsSsa/",
    "actions": [{ "action": "view", "label": "Admin panel", "url": "https://filesrv.lan/admin" }]
  }'
```

### Cronjobs

```bash
rsync -a root@laptop /backups/laptop \
  && zfs snapshot ... \
  && curl -H prio:low -d "Laptop backup succeeded" ntfy.sh/backups \
  || curl -H tags:warning -H prio:high -d "Laptop backup failed" ntfy.sh/backups
```

### Low disk space alerts

```bash
#!/bin/bash
mingigs=2
avail=$(df | awk '$6 == "/" && $4 < '$mingigs' * 1024*1024 { print $4/1024/1024 }')
topicurl=https://ntfy.sh/mytopic
token=tk_dak932jd93jasjdj299j9w8j

if [ -n "$avail" ]; then
  curl \
    -d "Only $avail GB available on the root disk. Better clean that up." \
    -H "Title: Low disk space alert on $(hostname)" \
    -H "Priority: high" \
    -H "Tags: warning,cd" \
    -H "Authorization: Bearer $token" \
    $topicurl
fi
```

### SSH login alerts

`/etc/pam.d/sshd`

```bash
# at the end of the file
session optional pam_exec.so /usr/bin/ntfy-ssh-login.sh
```

`/usr/bin/ntfy-ssh-login.sh`

```bash
#!/bin/bash
if [ "${PAM_TYPE}" = "open_session" ]; then
  curl \
  -H "Authorization: Bearer tk_" \
  -H tags:warning \
  -d "SSH login: ${PAM_USER} from ${PAM_RHOST}" \
  https://ntfy.domain.tld/ssh
fi
```

### Ansible

```yaml
- name: Send ntfy.sh update
  uri:
    url: "https://ntfy.sh/{{ ntfy_channel }}"
    method: POST
    body: "{{ inventory_hostname }} reseeding complete"
```

### Forgejo Actions

```bash
- name: Actions Ntfy
  run: |
    curl \
      -u ${{ secrets.NTFY_CRED }} \
      -H "Title: Title here" \
      -H "Content-Type: text/plain" \
      -d $'Repo: ${{ github.repository }}\nCommit: ${{ github.sha }}\nRef: ${{ github.ref }}\nStatus: ${{ job.status}}' \
      ${{ secrets.NTFY_URL }}
```

### Home Assistant

```yaml
notify:
  - name: ntfy
    platform: rest
    method: POST_JSON
    data:
      topic: YOUR_NTFY_TOPIC
    title_param_name: title
    message_param_name: message
    resource: https://ntfy.sh
```

See also homeassistant-ntfy integration: [https://github.com/ivanmihov/homeassistant-ntfy.sh](https://github.com/ivanmihov/homeassistant-ntfy.sh).

### Jellyseerr

```bash
{
    "topic": "requests",
    "title": "{{event}}",
    "message": "{{subject}}\n{{message}}\n\nRequested by: {{requestedBy_username}}\n\nStatus: {{media_status}}\nRequest Id: {{request_id}}",
    "priority": 4,
    "attach": "{{image}}",
    "click": "https://requests.example.com/{{media_type}}/{{media_tmdbid}}"
}
```

</details>