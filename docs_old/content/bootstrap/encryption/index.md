---
title: encryption
description: How secrets in the repository are encrypted with SOPS and age.
---

# encryption

All secrets in the repository are SOPS-encrypted with age keys before they are committed; Flux decrypts them in-cluster.

## Pages

| Page | Content |
| --- | --- |
| [sops-age](sops-age.md) | How to use SOPS and age with the clusters: keys, creation rules, creating and editing secrets, in-cluster decryption |
| [key rotation](key-rotation.md) | How to update or rotate age keys and re-encrypt all secrets |
