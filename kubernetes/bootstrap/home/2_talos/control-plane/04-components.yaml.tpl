---
# Controller-manager: expose metrics for scraping, allow HPA scale-to-zero (alpha; needs custom/external metrics).
apiVersion: v1alpha1
kind: KubeControllerManagerConfig
extraArgs:
  bind-address: 0.0.0.0
  feature-gates: HPAScaleToZero=true
image: registry.k8s.io/kube-controller-manager:{{ .KubernetesVersion }}

---
# Bind the scheduler's metrics/health endpoint to all interfaces so Prometheus can scrape it; pin the scheduler image.
apiVersion: v1alpha1
kind: KubeSchedulerConfig
extraArgs:
  bind-address: 0.0.0.0
image: registry.k8s.io/kube-scheduler:{{ .KubernetesVersion }}
