### OpenTofu ###
variable "tofu_passphrase" {
  description = "OpenTofu passphrase to encrypt statefiles"
  type        = string
  sensitive   = true
}

### hetzner ###
variable "hcloud_token" {
  description = "hetzner api token"
  sensitive   = true
}

### talos ###
variable "talos_version" {
  description = "talos version used to retrieve the template which will be used to start the nodes"
  type        = string
}

variable "controlplane_node" {
  description = "map of talos controlplane nodes"
  type        = string
  default     = "talos"
}

variable "arch" {
  description = "processor architecture amd64 or arm64"
  type        = string
  default     = "arm64"
}

variable "server_type" {
  description = "server type"
  type        = string
  default     = "cax21"
}

variable "server_location" {
  description = "hetzner datecenter location"
  type        = string
  default     = "fsn1-dc14"
}
