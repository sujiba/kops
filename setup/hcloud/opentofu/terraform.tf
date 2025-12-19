terraform {
  required_version = "1.11.2" # renovate: datasource=github-releases depName=opentofu/opentofu

  encryption {
    key_provider "pbkdf2" "home-lab-key" {
      passphrase = var.tofu_passphrase
    }
    method "aes_gcm" "encryption_method" {
      keys = key_provider.pbkdf2.home-lab-key
    }
    state {
      method = method.aes_gcm.encryption_method
    }
    plan {
      method = method.aes_gcm.encryption_method
    }
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.57"
    }
  }
}
