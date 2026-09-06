---
# Install Talos unattended to the selected disk using an Image Factory installer with your extensions baked in.
apiVersion: v1alpha1
kind: UnattendedInstallConfig
installer:
  image: factory.talos.dev/metal-installer/{{ .schematicId }}:{{ .talosVersion }}
provisioning:
  diskSelector:
    match: disk.serial == 'S65CNX1T325816' && disk.size < 1TB
  wipe: false
