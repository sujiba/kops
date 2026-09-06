---
# Use the local host DNS cache with an upstream resolver; keep KubeDNS traffic off the host resolver.
apiVersion: v1alpha1
kind: ResolverConfig
nameservers:
{{- range .Data.dnsIPv4 }}
  - address: {{ . }}
{{- end }}
searchDomains:
  disableDefault: true

---
# Sync time from the local gateway/router instead of the default time.cloudflare.com; keeps NTP traffic on-LAN.
apiVersion: v1alpha1
kind: TimeSyncConfig
ntp:
  servers:
    - 10.10.10.1

---
# Define the cluster's pod/service CIDRs and internal DNS domain.
apiVersion: v1alpha1
kind: KubeNetworkConfig
dnsDomain: cluster.local
podSubnets:
  - 10.244.0.0/16
serviceSubnets:
  - 10.96.0.0/12

---
# Remove the default Flannel CNI so a different CNI (e.g. Cilium) can be installed instead.
apiVersion: v1alpha1
kind: KubeFlannelCNIConfig
$patch: delete

---
# Disable kube-proxy; the replacement CNI (e.g. Cilium in kube-proxy-replacement mode) handles service routing via eBPF.
apiVersion: v1alpha1
kind: KubeProxyConfig
enabled: false
