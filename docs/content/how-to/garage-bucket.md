---
icon: lucide/archive
---

# Garage bucket

| | |
|---|---|
| **When** | A new S3 bucket is needed: a static site or CDN (public), or a backup target (private) |
| **Duration** | about 10 minutes |
| **Risk** | Low: only affects the new bucket. Medium if a private bucket is accidentally made public |

## Prerequisites

- [ ] `kubectl` access to the cluster `hcloud`
- [ ] Decided: public or private (see below)

## Public or private?

Garage serves every bucket through the S3 API (port `3900`, only with a key). A bucket with `website.enabled` is also served through the web endpoint (port `3902`), **anonymously and without a key**.

| | Public (website) | Private |
|---|---|---|
| **Use for** | Static sites (these docs), CDN assets (`cdn`) | Backups, e.g. a kopiur repository or CNPG Barman Cloud |
| **`website`** | `enabled: true` | leave out |
| **`globalAlias`** | Must equal the hostname, e.g. `docs.${EXTERNAL_DOMAIN}` | Free name, e.g. `cnpg-backup` |
| **Readable by** | Everyone, via an `HTTPRoute` to port `3902` | Only holders of a key, via the S3 API |
| **Key** | Write key for the deploy pipeline | Read/write key for the backup tool |

!!! danger "Never put backups in a website bucket"

    Everything in a bucket with `website.enabled` is readable on the internet as soon as an `HTTPRoute` points at its hostname. Backups, dumps and anything with personal data belong in a private bucket.

!!! warning "Garage has a single copy"

    `garage-cluster` runs on one node with `replication.factor: 1`. A backup stored there is only as safe as that disk. Today kopiur writes to Hetzner Object Storage (`kopiur-backup`), not to Garage.

## Steps

All manifests live in `kubernetes/hcloud/apps/garage-system/garage/app/`.

1. Declare the bucket in `buckets.yaml`:

    === "Public"

        ```yaml title="buckets.yaml"
        ---
        apiVersion: garage.rajsingh.info/v1beta1
        kind: GarageBucket
        metadata:
          name: docs
        spec:
          clusterRef:
            name: garage-cluster
          # Garage picks the website bucket by the Host header
          globalAlias: docs.${EXTERNAL_DOMAIN}
          website:
            enabled: true
            indexDocument: index.html
            errorDocument: 404.html
        ```

    === "Private"

        ```yaml title="buckets.yaml"
        ---
        apiVersion: garage.rajsingh.info/v1beta1
        kind: GarageBucket
        metadata:
          name: cnpg-backup
        spec:
          clusterRef:
            name: garage-cluster
          globalAlias: cnpg-backup
          quotas:
            maxSize: 20Gi
        ```

    `quotas.maxSize` is optional but protects the 10 Gi data volume of `garage-cluster` from a runaway backup job.

2. Declare a key with access to the bucket in `keys.yaml`:

    ```yaml title="keys.yaml"
    ---
    apiVersion: garage.rajsingh.info/v1beta1
    kind: GarageKey
    metadata:
      name: docs-key
    spec:
      clusterRef:
        name: garage-cluster
      bucketPermissions:
        - bucketRef:
            name: docs
          read: true
          write: true
    ```

    One key per consumer. Do not reuse a key across buckets or apps.

3. Public only: route the hostname to the web endpoint in `httproute.yaml`:

    ```yaml title="httproute.yaml"
    ---
    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: garage-docs
    spec:
      parentRefs:
        - name: envoy-external
          namespace: network
          sectionName: https
      hostnames:
        - docs.${EXTERNAL_DOMAIN}
      rules:
        - backendRefs:
            - name: garage-cluster
              port: 3902
    ```

4. Commit, push, and wait until Flux has applied the Kustomization `garage`.
5. Read the credentials from the secret the operator creates with the key's name:

    ```bash
    kubectl -n garage-system get secret docs-key \
      -o go-template='{{index .data "access-key-id" | base64decode}}{{"\n"}}{{index .data "secret-access-key" | base64decode}}{{"\n"}}'
    ```

6. Hand the credentials to the consumer:

    === "Forgejo Actions (these docs)"

        Store them in the repo [homelab/kops](https://code.offene.cloud/homelab/kops) under *Settings → Actions → Secrets*:

        | Secret | Value |
        |---|---|
        | `GARAGE_ACCESS_KEY_ID` | `access-key-id` |
        | `GARAGE_SECRET_ACCESS_KEY` | `secret-access-key` |

    === "App in a cluster"

        Put them into the app's `secrets.sops.yaml` and point the app at the S3 API:

        | Setting | Inside `hcloud` | From `home` |
        |---|---|---|
        | Endpoint | `http://garage-cluster.garage-system.svc:3900` | `https://s3.${EXTERNAL_DOMAIN}` |
        | Region | `hcloud` | `hcloud` |
        | Addressing | path-style | path-style |

        Only `s3.${EXTERNAL_DOMAIN}` is routed, so virtual-host-style URLs (`<bucket>.s3.…`) do not resolve.

??? note "Alternative: manually via the Garage CLI"

    Only if the operator is not available. The commands run in the Garage pod (`kubectl -n garage-system exec -it <garage-pod> -- /garage …`):

    ```bash
    garage bucket create docs.offene.cloud
    garage bucket website --allow --index-document index.html --error-document 404.html docs.offene.cloud
    garage key create docs-key
    garage bucket allow --read --write docs.offene.cloud --key docs-key
    ```

    Leave out `garage bucket website` for a private bucket.

## Verify

```bash
kubectl -n garage-system get garagebucket
kubectl -n garage-system get garagekey
```

Bucket and key must be `Ready`.

Public bucket, after the first upload: the web endpoint serves the start page.

```bash
kubectl -n garage-system run curl --rm -it --image=curlimages/curl --restart=Never -- \
  curl -sI -H "Host: docs.offene.cloud" http://garage-cluster:3902/
```

Expected: `HTTP/1.1 200 OK`.

Private bucket: the same request with its alias must **not** return `200`.

## Rollback

Remove the `GarageBucket`, `GarageKey` and, if present, the `HTTPRoute` from the YAML files and delete the consumer's secrets. For a public site nothing is lost, it can be rebuilt and uploaded again. For a private bucket, move the data elsewhere first.
