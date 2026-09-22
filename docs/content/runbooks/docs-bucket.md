# Doku-Bucket

| | |
|---|---|
| **Wann** | Einmalig: Bucket und Deploy-Key für diese Doku einrichten, oder nach Verlust des Buckets |
| **Dauer** | ca. 10 Minuten |
| **Risiko** | Gering: betrifft nur die Doku |

## Voraussetzungen

- [ ] `kubectl`-Zugriff auf den Cluster `hcloud`
- [ ] Admin-Rechte im Forgejo-Repo [homelab/kops](https://code.offene.cloud/homelab/kops) (für Secrets)

!!! warning "Bucket-Name = Domain"

    Garage wählt den Website-Bucket anhand des `Host`-Headers. Der globale Alias des Buckets muss daher exakt `docs.offene.cloud` heißen.

## Schritte

1. Bucket und Key deklarativ in `kubernetes/hcloud/apps/garage-system/garage/app/` anlegen:

    ```yaml title="buckets.yaml"
    ---
    apiVersion: garage.rajsingh.info/v1beta1
    kind: GarageBucket
    metadata:
      name: docs
    spec:
      clusterRef:
        name: garage-cluster
      globalAlias: docs.${EXTERNAL_DOMAIN}
      website:
        enabled: true
        indexDocument: index.html
        errorDocument: 404.html
    ```

    ```yaml title="keys.yaml"
    ---
    apiVersion: garage.rajsingh.info/v1beta1
    kind: GarageKey
    metadata:
      name: docs-deploy
    spec:
      clusterRef:
        name: garage-cluster
      bucketPermissions:
        - bucketRef:
            name: docs
          read: true
          write: true
    ```

2. Commit, Push, warten bis Flux die Kustomization `garage` angewendet hat.
3. Zugangsdaten aus dem vom Operator erzeugten Secret lesen:

    ```bash
    kubectl -n garage-system get secret docs-deploy \
      -o go-template='{{index .data "access-key-id" | base64decode}}{{"\n"}}{{index .data "secret-access-key" | base64decode}}{{"\n"}}'
    ```

4. In Forgejo unter *Einstellungen → Actions → Secrets* hinterlegen:

    | Secret | Wert |
    |---|---|
    | `GARAGE_ACCESS_KEY_ID` | `access-key-id` |
    | `GARAGE_SECRET_ACCESS_KEY` | `secret-access-key` |

??? note "Alternative: manuell per Garage-CLI"

    Nur falls der Operator nicht verfügbar ist. Die Befehle laufen im Garage-Pod (`kubectl -n garage-system exec -it <garage-pod> -- /garage …`):

    ```bash
    garage bucket create docs.offene.cloud
    garage bucket website --allow --index-document index.html --error-document 404.html docs.offene.cloud
    garage key create docs-deploy
    garage bucket allow --read --write docs.offene.cloud --key docs-deploy
    ```

## Prüfen

```bash
kubectl -n garage-system get garagebucket docs
kubectl -n garage-system get garagekey docs-deploy
```

Beide müssen `Ready` sein. Nach dem ersten Deploy liefert der Web-Endpoint die Startseite aus:

```bash
kubectl -n garage-system run curl --rm -it --image=curlimages/curl --restart=Never -- \
  curl -sI -H "Host: docs.offene.cloud" http://garage-cluster:3902/
```

Erwartet: `HTTP/1.1 200 OK`.

## Rollback

`GarageBucket` und `GarageKey` aus den YAML-Dateien entfernen und die Forgejo-Secrets löschen. Die Doku lässt sich jederzeit neu bauen und hochladen, es gehen keine Daten verloren.
