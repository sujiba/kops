
# create firewall
resource "hcloud_firewall" "k8s_firewall" {
  name = "k8s-firewall"
  rule {
    description = "ping"
    direction   = "in"
    protocol    = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "http"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "https"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "k8s api"
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "talos api"
    direction   = "in"
    protocol    = "tcp"
    port        = "50000"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

# create controlplane node
resource "hcloud_server" "controlplane" {
  name        = var.controlplane_node
  image       = "debian-13"
  server_type = var.server_type
  datacenter  = var.server_location
  ssh_keys    = data.hcloud_ssh_keys.all.ssh_keys.*.name
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
    ipv4         = data.hcloud_primary_ip.ip_v4.id
  }
  rescue = "linux64"
  connection {
    host        = self.ipv4_address
    agent       = true
    user        = "root"
    private_key = file("~/.ssh/id_ed25519_init")
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y wget",
      "wget -O /tmp/talos.raw.xz ${local.image}",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
      "shutdown -r now"
    ]
  }
}

# attach controlplane to private network
resource "hcloud_server_network" "srvnetwork" {
  server_id  = hcloud_server.controlplane.id
  network_id = data.hcloud_network.internal.id
  ip         = "10.10.11.4"
}

# attach controlplane to firewall
resource "hcloud_firewall_attachment" "fw_ref" {
  firewall_id = hcloud_firewall.k8s_firewall.id
  server_ids  = [hcloud_server.controlplane.id]
}

output "ipv4_address" {
  value = hcloud_server.controlplane.ipv4_address
}