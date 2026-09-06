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

---
# Sync time from PTB (German national metrology institute) and the European pool; avoids Cloudflare.
apiVersion: v1alpha1
kind: TimeSyncConfig
ntp:
  servers:
    - ptbtime1.ptb.de
    - europe.pool.ntp.org

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
