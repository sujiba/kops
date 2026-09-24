# Docs bucket

| | |
|---|---|
| **When** | Once: set up the bucket and deploy key for these docs, or after losing the bucket |
| **Duration** | about 10 minutes |
| **Risk** | Low: only affects the docs |

## Prerequisites

- [ ] `kubectl` access to the cluster `hcloud`
- [ ] Admin rights in the Forgejo repo [homelab/kops](https://code.offene.cloud/homelab/kops) (for secrets)

!!! warning "Bucket name = domain"

    Garage picks the website bucket by the `Host` header. The bucket's global alias must therefore be exactly `docs.offene.cloud`.

## Steps

1. Declare bucket and key in `kubernetes/hcloud/apps/garage-system/garage/app/`:

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

2. Commit, push, and wait until Flux has applied the Kustomization `garage`.
3. Read the credentials from the secret created by the operator:

    ```bash
    kubectl -n garage-system get secret docs-deploy \
      -o go-template='{{index .data "access-key-id" | base64decode}}{{"\n"}}{{index .data "secret-access-key" | base64decode}}{{"\n"}}'
    ```

4. Store them in Forgejo under *Settings → Actions → Secrets*:

    | Secret | Value |
    |---|---|
    | `GARAGE_ACCESS_KEY_ID` | `access-key-id` |
    | `GARAGE_SECRET_ACCESS_KEY` | `secret-access-key` |

??? note "Alternative: manually via the Garage CLI"

    Only if the operator is not available. The commands run in the Garage pod (`kubectl -n garage-system exec -it <garage-pod> -- /garage …`):

    ```bash
    garage bucket create docs.offene.cloud
    garage bucket website --allow --index-document index.html --error-document 404.html docs.offene.cloud
    garage key create docs-deploy
    garage bucket allow --read --write docs.offene.cloud --key docs-deploy
    ```

## Verify

```bash
kubectl -n garage-system get garagebucket docs
kubectl -n garage-system get garagekey docs-deploy
```

Both must be `Ready`. After the first deploy, the web endpoint serves the start page:

```bash
kubectl -n garage-system run curl --rm -it --image=curlimages/curl --restart=Never -- \
  curl -sI -H "Host: docs.offene.cloud" http://garage-cluster:3902/
```

Expected: `HTTP/1.1 200 OK`.

## Rollback

Remove `GarageBucket` and `GarageKey` from the YAML files and delete the Forgejo secrets. The docs can be rebuilt and uploaded at any time, no data is lost.
