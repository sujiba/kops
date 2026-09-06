---
# API server: enable aggregation-layer routing, allow HPA scale-to-zero, and add KubePrism + LAN IP to the cert SANs.
apiVersion: v1alpha1
kind: KubeAPIServerConfig
image: registry.k8s.io/kube-apiserver:{{ .KubernetesVersion }}
extraArgs:
  enable-aggregator-routing: "true"
  feature-gates: HPAScaleToZero=true
certExtraSANs:
  - 127.0.0.1 # KubePrism
  - {{ .Data.privateClusterIP }} # home network
