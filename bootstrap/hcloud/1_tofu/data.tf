# data sources

### hetzner ###
# get a list of all ssh keys
data "hcloud_ssh_keys" "all" {}

data "hcloud_network" "internal" {
  name = "internal"
}

data "hcloud_primary_ip" "ip_v4" {
  ip_address = "91.98.37.31"
}