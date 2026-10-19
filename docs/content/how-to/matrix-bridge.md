---
icon: lucide/cable
---

# Matrix bridge

| | |
|---|---|
| **When** | A mautrix bridge (WhatsApp, Discord) has been deployed and must be registered with Continuwuity, cluster `hcloud` only |
| **Duration** | about 10 minutes |
| **Risk** | Low: only affects the bridge. The registration reserves the user IDs `@<bot>` and `@<prefix>_*` on the homeserver |

## Prerequisites

- [ ] The bridge's `ks.yaml` is enabled in [`matrix/kustomization.yaml`](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/hcloud/apps/matrix/kustomization.yaml) and its pod is `Running`
- [ ] `sops` with the age key for `kubernetes/hcloud`, and `yq`
- [ ] Your Matrix account is a server admin and can write in the Continuwuity admin room

| Bridge | Manifests | Appservice ID | Bot | Prefix |
|---|---|---|---|---|
| WhatsApp | [`mautrix-whatsapp/app`](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/hcloud/apps/matrix/mautrix-whatsapp/app) | `whatsapp2` | `@whatsappbot` | `!wa` |
| Discord | [`mautrix-discord/app`](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/hcloud/apps/matrix/mautrix-discord/app) | `discord` | `@discordbot` | `!discord` |

??? note "Why the registration is done by hand"

    Continuwuity does not read registration files from disk; appservices are registered through the admin room. The bridge does not need the registration at runtime. The bridge's `secrets.sops.yaml` holds two secrets: `mautrix-<bridge>-secret` with the tokens the bridge reads at startup (WhatsApp from `MAUTRIX_WHATSAPP_*` environment variables, Discord through the `yq` init container; the config in Git only contains `set-from-secret`), and `mautrix-<bridge>-registration` with the filled-in registration. When rotating a token, change it in both secrets and register the bridge again.

## Steps

1. Check that the bridge is running:

    ```bash
    kubectl --kubeconfig ~/.kube/hcloud -n matrix get pods | grep mautrix
    ```

2. Print the filled-in registration:

    === "WhatsApp"

        ```bash
        sops -d kubernetes/hcloud/apps/matrix/mautrix-whatsapp/app/secrets.sops.yaml \
          | yq 'select(.metadata.name == "mautrix-whatsapp-registration") | .stringData["registration.yaml"]'
        ```

    === "Discord"

        ```bash
        sops -d kubernetes/hcloud/apps/matrix/mautrix-discord/app/secrets.sops.yaml \
          | yq 'select(.metadata.name == "mautrix-discord-registration") | .stringData["registration.yaml"]'
        ```

3. In the Continuwuity admin room, send the command with the registration from step 2 as a code block in the same message:

    ~~~~markdown
    !admin appservices register
    ```yaml
    id: whatsapp
    url: http://mautrix-whatsapp.matrix.svc:29318
    as_token: …
    hs_token: …
    …
    ```
    ~~~~

4. Create a normal room, not a direct chat, optionally inside a space (e.g. *WhatsApp*), and invite the bot (e.g. `@whatsappbot:matrix.<domain>`). It accepts the invite on its own. Send `help` with the bridge's prefix, then log in:

    === "WhatsApp"

        Send `!wa help`, then `!wa login qr` and scan the code in WhatsApp under *Settings → Linked devices → Link a device*.

        If the bot answers *This is not your management room*, another room (e.g. an earlier direct chat with the bot) is still your management room. Make this room the management room, then you can leave the old one:

        ```text
        !wa set-management-room
        ```

    === "Discord"

        Send `!discord help`, then `!discord login` and follow the bot's instructions.

    The bridge then creates a room for each chat. The first sync can take a few minutes.

    ??? note "Why not a direct chat"

        A direct chat is listed in your `m.direct` account data, so Sable and Cinny show it under Direct Messages even when it is also part of a space. A normal room only shows up in its space.

        The bridge has one management room per user, where commands work without the prefix. In any other room the bot is in, commands work with the prefix, including input in the middle of a login.

## Verify

In the admin room:

```text
!admin appservices list
```

Expected: the appservice ID is listed. `!admin appservices show-appservice-config <id>` shows the registration as stored; check `url` and the user regexes.

The bot is a member of the management room (not just invited) and answers `!wa help` or `!discord help`. The bridge logs show no `ERR` lines:

```bash
kubectl --kubeconfig ~/.kube/hcloud -n matrix logs deploy/mautrix-whatsapp --since=10m | grep -v '/sync'
```

## Rollback

1. Log out in the management room (`!wa help` or `!discord help` lists the command), so the bridge unlinks its device.
2. In the admin room:

    ```text
    !admin appservices unregister <id>
    ```

3. To remove the bridge completely, comment out its `ks.yaml` in `matrix/kustomization.yaml` again. Flux prunes the bridge and its CNPG cluster, including the database.
