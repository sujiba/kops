---
# Host DNS cache resolving upstream to Quad9 over DoT (encrypted); 9.9.9.10 is the no-threat-blocking endpoint.
apiVersion: v1alpha1
kind: ResolverConfig
hostDNS:
  enabled: true
nameservers:
  - address: 9.9.9.10
    protocol: DoT
    tlsServerName: dns10.quad9.net
  - address: 9.9.9.10   # plaintext fallback for boot

---
# NTS-authenticated time from the Trifecta Tech NTS pool (community-run; avoids cloudflare)
apiVersion: v1alpha1
kind: TimeSyncConfig
ntp:
  servers:
    - 0.ke.sectime.org
    - 1.ke.sectime.org
    - 2.ke.sectime.org
    - 3.ke.sectime.org
  useNTS: true

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
