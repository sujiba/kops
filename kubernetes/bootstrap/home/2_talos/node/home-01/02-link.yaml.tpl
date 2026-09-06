---
apiVersion: v1alpha1
kind: LinkAliasConfig
# Gives the onboard NIC a stable name, independent of PCI enumeration.
# Background: a second NVMe in slot 2 shifts the PCI addresses, which renamed
# the interface from enp86s0 to enp87s0. The LinkConfig then matched nothing and
# the node dropped off the network. permanent_addr is the MAC burned into the
# NIC and is unaffected by that renumbering.
name: net0
selector:
  match: mac(link.permanent_addr).startsWith("88:ae:dd:68:")

---
apiVersion: v1alpha1
kind: LinkConfig
# net0 is the alias defined in LinkAliasConfig, not the kernel name.
name: net0
addresses:
  - address: {{ .Node.IP }}/24
routes:
  - gateway: {{ .Data.gateway }}
