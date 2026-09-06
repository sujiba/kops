---
# Set the node's hostname from topf's per-node value; disable auto-hostname from DHCP/platform.
apiVersion: v1alpha1
kind: HostnameConfig
auto: "off"
hostname: {{ .Node.Host }}
