---
# Set the node's hostname from topf's per-node value; disable auto-hostname from DHCP/platform.
apiVersion: v1alpha1
kind: HostnameConfig
auto: "off"
hostname: {{ .Node.Host }}

---
# Install Talos unattended to the selected disk using an Image Factory installer with your extensions baked in.
apiVersion: v1alpha1
kind: UnattendedInstallConfig
installer:
  image: factory.talos.dev/metal-installer/{{ .SchematicId }}:{{ .TalosVersion }}
provisioning:
  diskSelector:
    match: disk.serial == '{{ .Node.Data.installDisk }}' && disk.size < 1TB
  wipe: false
