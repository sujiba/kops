---
# Kubelet: image GC and pull tuning, 200-pod cap, graceful shutdown windows, seccomp by default.
# maxContainerRestartPeriod caps the CrashLoopBackOff delay at 60s instead of the default 5m.
apiVersion: v1alpha1
kind: KubeletConfig
config:
  crashLoopBackOff:
    maxContainerRestartPeriod: 60s
  imageMaximumGCAge: 168h
  maxParallelImagePulls: 3
  maxPods: 200
  serializeImagePulls: false
  shutdownGracePeriod: 90s
  shutdownGracePeriodCriticalPods: 60s
defaultRuntimeSeccompProfileEnabled: true
image: ghcr.io/siderolabs/kubelet:{{ .KubernetesVersion }}
