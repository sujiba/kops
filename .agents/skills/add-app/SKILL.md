---
name: add-app
description: Use when deploying a new application to a Kubernetes cluster (hcloud or home) — scaffolding a Flux Kustomization plus app-template HelmRelease under kubernetes/<cluster>/apps/ (new app, new service, "add X to the cluster")
---

# Add a New Application

Scaffolds `kubernetes/<cluster>/apps/<namespace>/<app>/` with a Flux Kustomization (`ks.yaml`) and an app-template HelmRelease. There are two clusters with their own apps, components and Flux instance:

| Cluster | Persistence | Components |
| --- | --- | --- |
| `hcloud` (Hetzner, node `talos`) | plain PVC in `app/pvc.yaml`, `openebs-hostpath`, no backup | `common`, `dragonfly`, `anubis`, `zeroscaler` |
| `home` (node `home-01`) | kopiur backup component (PVC on `miroir-local`, snapshots, restore) | `common`, `dragonfly`, `kopiur`, `zeroscaler` |

Every value below comes from current repo conventions. When in doubt, mirror a real app instead of inventing structure:

| Reference app | Shows |
| --- | --- |
| `kubernetes/hcloud/apps/selfhosted/it-tools` | Minimal stateless app + public route |
| `kubernetes/home/apps/selfhosted/vaultwarden` | sops secret, kopiur-backed persistence, internal route |
| `kubernetes/hcloud/apps/selfhosted/tandoor` | Plain PVC, sops secret, database |

## Step 1: Gather details

Ask the user (AskUserQuestion) for anything not already given:

1. **Cluster** (`hcloud` or `home`), **app name** and **namespace** (existing dirs: `ls kubernetes/<cluster>/apps/`)
2. **Image** repository + tag (upstream's current release)
3. **Port** the app listens on, and whether it gets a **route**: internal (`envoy-internal`, `${INTERNAL_DOMAIN}`) or public (`envoy-external`, `${EXTERNAL_DOMAIN}`)
4. **Persistence**: does the app store state? (home → kopiur component, hcloud → `pvc.yaml`)
5. **Secrets**: which env vars? They go into a sops-encrypted `secrets.sops.yaml`. Get the key names; the user fills in or provides the values, never invent them
6. **Config files**: mounted config? (→ configMapGenerator + `resources/`)
7. **Dependencies**: other Flux Kustomizations this app needs

## Step 2: Create the files

Layout:

```
kubernetes/<cluster>/apps/<namespace>/<app>/
├── ks.yaml
└── app/
    ├── kustomization.yaml
    ├── ocirepository.yaml
    ├── helmrelease.yaml
    ├── pvc.yaml                 # hcloud only, if persistence
    ├── secrets.sops.yaml        # only if secrets
    └── resources/               # only if config files
```

### ks.yaml

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: <app>
spec:
  interval: 1h
  path: ./kubernetes/<cluster>/apps/<namespace>/<app>/app
  postBuild:
    substituteFrom:
      - name: cluster-secrets
        kind: Secret
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
    namespace: flux-system
  targetNamespace: <namespace>
  wait: false
```

`postBuild.substituteFrom` with `cluster-secrets` is what resolves `${EXTERNAL_DOMAIN}`, `${INTERNAL_DOMAIN}`, `${MAIL_DOMAIN}` and friends; keep it on every app. The repo keeps an explicit `wait: false`. Use `wait: true` only when another Kustomization will `dependsOn` this one (as for cert-manager or miroir).

**Dependencies** go into `spec.dependsOn`; add `namespace:` when the dependency lives in another namespace:

```yaml
dependsOn:
  - name: litellm-operator
    namespace: ai
```

**home: if the app has persistence**, add the kopiur component (see `kubernetes/home/components/kopiur/backup/` for all knobs and defaults). Most stateful apps use `prune: false` so a removed manifest does not delete the PVC; ask the user if unsure:

```yaml
spec:
  components:
    - ../../../../components/kopiur/backup
  postBuild:
    substituteFrom:
      - name: cluster-secrets
        kind: Secret
    substitute:
      APP: <app>
      # Optional overrides, only when defaults don't fit:
      # KOPIUR_CAPACITY: 10Gi       # default: 5Gi
      # KOPIUR_PUID: "2000"         # default: 1000, must match the pod's runAsUser
      # KOPIUR_PGID: "2000"         # default: 1000
      # KOPIUR_STORAGECLASS: …      # default: miroir-local
```

The component creates a PVC named `<app>` (`${APP}`).

### app/kustomization.yaml

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: <namespace>

resources:
  - ./helmrelease.yaml
  - ./ocirepository.yaml
  - ./pvc.yaml           # hcloud only, if persistence
  - ./secrets.sops.yaml  # only if secrets
```

**If the app mounts config files**, put them in `resources/` and append:

```yaml
configMapGenerator:
  - name: <app>-configmap
    files:
      - config.yaml=./resources/config.yaml
generatorOptions:
  disableNameSuffixHash: true
  annotations:
    kustomize.toolkit.fluxcd.io/substitute: disabled
```

### app/ocirepository.yaml

```yaml
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: OCIRepository
metadata:
  name: <app>
spec:
  interval: 15m
  layerSelector:
    mediaType: application/vnd.cncf.helm.chart.content.v1.tar+gzip
    operation: copy
  ref:
    tag: <version>
  url: oci://ghcr.io/bjw-s-labs/helm/app-template
```

**Never hardcode `<version>` from memory**. Use the version the rest of the repo is on:

```bash
grep -h -A1 "ref:" $(grep -l app-template kubernetes/*/apps/*/*/app/ocirepository.yaml) | grep tag: | sort | uniq -c | sort -rn | head -1
```

### app/helmrelease.yaml

```yaml
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: <app>
spec:
  chartRef:
    kind: OCIRepository
    name: <app>
  interval: 1h
  values:
    controllers:
      <app>:
        annotations:
          reloader.stakater.com/auto: "true"
        pod:
          securityContext:
            runAsGroup: 2000
            runAsNonRoot: true
            runAsUser: 2000
        containers:
          app:
            image:
              repository: <image-repo>
              tag: <image-tag>
            resources:
              requests:
                cpu: 5m
                memory: 32Mi
              limits:
                memory: 256Mi
            securityContext:
              allowPrivilegeEscalation: false
              capabilities: {drop: ["ALL"]}
              readOnlyRootFilesystem: true
    persistence:
      tmpfs: # writable /tmp for readOnlyRootFilesystem
        type: emptyDir
        globalMounts:
          - path: /tmp
    service:
      app:
        ports:
          http:
            port: <port>
```

Adjust `runAsUser`/`runAsGroup` (and capabilities) to what the image requires; drop the pod `securityContext` only if the image genuinely can't run non-root. Plain image tags are fine: Renovate pins digests and manages updates.

**Optional value blocks** (top-level under `values`, alphabetical: `controllers`, `persistence`, `route`, `service`):

Route (web UI/API):

```yaml
route:
  app:
    hostnames: ["<app>.${INTERNAL_DOMAIN}"] # ${EXTERNAL_DOMAIN} for public apps
    parentRefs:
      - name: envoy-internal # envoy-external for public apps
        namespace: network
        sectionName: https
```

Persistence (also add `fsGroup` + `fsGroupChangePolicy: OnRootMismatch` to the pod securityContext):

```yaml
persistence:
  data:
    existingClaim: <app> # home: PVC from the kopiur component; hcloud: name from pvc.yaml
    globalMounts:
      - path: /data
```

hcloud `app/pvc.yaml` (mirror `tandoor`):

```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: <app>-data-pvc
  namespace: <namespace>
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: openebs-hostpath
```

Config file mount (pairs with configMapGenerator):

```yaml
persistence:
  config:
    type: configMap
    name: <app>-configmap
    globalMounts:
      - path: /config/config.yaml
        subPath: config.yaml
        readOnly: true
```

Secrets: add to the container:

```yaml
envFrom:
  - secretRef:
      name: <app>-secret
```

### app/secrets.sops.yaml (only if secrets)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <app>-secret
  namespace: <namespace>
stringData:
  SOME_ENV_VAR: <value>
```

Encrypt in place before committing: `sops -e -i kubernetes/<cluster>/apps/<namespace>/<app>/app/secrets.sops.yaml`. The rules in `.sops.yaml` match `kubernetes/<cluster>/**/*.sops.yaml` and only encrypt `data`/`stringData`. **Never commit an unencrypted secret**: check that the values read `ENC[...]`. If the user has not given values, leave `<FIXME>` placeholders, do not encrypt, and tell the user to fill them in and run `sops -e -i`.

## Step 3: Register in the namespace kustomization

Add `./<app>/ks.yaml` to `kubernetes/<cluster>/apps/<namespace>/kustomization.yaml` `resources`, in alphabetical position among the app entries (`namespace.yaml` stays first; leave existing entries where they are).

**New namespace?** Create `kubernetes/<cluster>/apps/<namespace>/` with a `namespace.yaml` and `kustomization.yaml` copied from an existing namespace of the same cluster (e.g. `selfhosted`). Keep its components: `common` (cluster-secrets) on both clusters, plus `kopiur/secret` on home if any app in the namespace uses kopiur. No further registration is needed: `kubernetes/<cluster>/flux/cluster.yaml` points at `kubernetes/<cluster>/apps`, and Flux picks up every namespace directory.

## Step 4: Verify

```bash
kustomize build kubernetes/<cluster>/apps/<namespace>/<app>/app   # must render; ${VAR}s staying literal is expected
yamllint --config-file .yamllint.yaml kubernetes/<cluster>/apps/<namespace>/<app>
```

Show the user the created files and get confirmation before committing. Commit style: `feat(<namespace>): added <app>`.

## Step 5: Document the app

If the app needs an operational procedure (runbook) or reflects a design decision (ADR), document it with the `add-docs` skill (`.agents/skills/add-docs/SKILL.md`).

## Common mistakes

- **Wrong cluster path**: apps live under `kubernetes/<cluster>/apps/`, components under `kubernetes/<cluster>/components/`; the relative `../../../../components/...` path resolves inside the same cluster.
- **Copying a chart version or image tag from this skill or memory**: always read the current version from the repo (Step 2 command) and upstream.
- **Using volsync or kopiur on hcloud**: `hcloud/components/volsync` is unused and kopiur only exists on home.
- **Hardcoding a domain**: use `${INTERNAL_DOMAIN}` / `${EXTERNAL_DOMAIN}` and keep `substituteFrom: cluster-secrets` in `ks.yaml`.
- **Forgetting `sectionName: https`** on the route's `parentRefs`.
- **Forgetting `reloader.stakater.com/auto`**: without it, secret/config changes don't restart pods.
- **`readOnlyRootFilesystem: true` without a tmpfs**: apps that write to `/tmp` will crash; mount an emptyDir.
- **Committing an unencrypted `secrets.sops.yaml`**.
- **Skipping the sorting conventions**: HelmRelease values follow `.agents/instructions/sorting.instructions.md`.
