---
# Kubelet: graceful node shutdown windows, seccomp by default, pinned kubelet image.
apiVersion: v1alpha1
kind: KubeletConfig
config:
  shutdownGracePeriod: 90s
  shutdownGracePeriodCriticalPods: 60s
defaultRuntimeSeccompProfileEnabled: true
image: ghcr.io/siderolabs/kubelet:{{ .kubernetesVersion }}
