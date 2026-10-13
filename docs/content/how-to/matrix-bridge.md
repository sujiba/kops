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
- [ ] `sops` with the age key for `kubernetes/hcloud`
- [ ] Your Matrix account is a server admin and can write in the Continuwuity admin room

| Bridge | Manifests | Appservice ID | Bot |
|---|---|---|---|
| WhatsApp | [`mautrix-whatsapp/app`](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/hcloud/apps/matrix/mautrix-whatsapp/app) | `whatsapp2` | `@whatsappbot` |
| Discord | [`mautrix-discord/app`](https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/hcloud/apps/matrix/mautrix-discord/app) | `discord` | `@discordbot` |

??? note "Why the registration is done by hand"

    Continuwuity does not read registration files from disk; appservices are registered through the admin room. The bridge does not need the registration at runtime, so it is not deployed with tokens. The tokens live in the bridge's `secrets.sops.yaml` and reach the bridge at startup: WhatsApp reads them from `MAUTRIX_WHATSAPP_*` environment variables, Discord gets them written into its config by the `yq` init container. The config in Git only contains `set-from-secret`.

## Steps

1. Check that the bridge is running:

    ```bash
    kubectl --kubeconfig ~/.kube/hcloud -n matrix get pods | grep mautrix
    ```

2. Read the two tokens from the bridge's secret:

    === "WhatsApp"

        ```bash
        cd kubernetes/hcloud/apps/matrix/mautrix-whatsapp/app
        sops -d --extract '["stringData"]["MAUTRIX_WHATSAPP_APPSERVICE__AS_TOKEN"]' secrets.sops.yaml
        sops -d --extract '["stringData"]["MAUTRIX_WHATSAPP_APPSERVICE__HS_TOKEN"]' secrets.sops.yaml
        ```

    === "Discord"

        ```bash
        cd kubernetes/hcloud/apps/matrix/mautrix-discord/app
        sops -d --extract '["stringData"]["AS_TOKEN"]' secrets.sops.yaml
        sops -d --extract '["stringData"]["HS_TOKEN"]' secrets.sops.yaml
        ```

3. Copy `resources/registration.yaml` of the bridge into a scratch buffer (not into the repo) and fill it in:

    | Placeholder | Replace with |
    |---|---|
    | `{{ .AS_TOKEN }}` | the `AS_TOKEN` from step 2 |
    | `{{ .HS_TOKEN }}` | the `HS_TOKEN` from step 2 |
    | `${EXTERNAL_DOMAIN}` | the external domain, without `matrix.` |

4. In the Continuwuity admin room, send the command with the filled-in registration as a code block in the same message:

    ~~~~markdown
    !admin appservices register
    ```yaml
    id: whatsapp2
    url: http://mautrix-whatsapp.matrix.svc:29318
    as_token: <AS_TOKEN>
    hs_token: <HS_TOKEN>
    …
    ```
    ~~~~

5. Open a direct chat with the bot (e.g. `@whatsappbot:matrix.<domain>`). It accepts the invite on its own. Send `help`, then log in:

    === "WhatsApp"

        Send `login qr` and scan the code in WhatsApp under *Settings → Linked devices → Link a device*.

    === "Discord"

        Send `login` and follow the bot's instructions.

    The bridge then creates a room for each chat. The first sync can take a few minutes.

## Verify

In the admin room:

```text
!admin appservices list
```

Expected: the appservice ID is listed. `!admin appservices show-appservice-config <id>` shows the registration as stored; check `url` and the user regexes.

The bot is a member of the direct chat (not just invited) and answers `help`. The bridge logs show no `ERR` lines:

```bash
kubectl --kubeconfig ~/.kube/hcloud -n matrix logs deploy/mautrix-whatsapp --since=10m | grep -v '/sync'
```

## Rollback

1. Log out in the direct chat with the bot (`help` lists the command), so the bridge unlinks its device.
2. In the admin room:

    ```text
    !admin appservices unregister <id>
    ```

3. To remove the bridge completely, comment out its `ks.yaml` in `matrix/kustomization.yaml` again. Flux prunes the bridge and its CNPG cluster, including the database.
