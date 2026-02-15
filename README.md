# terraform-proxmox-k3s

OpenTofu module for deploying k3s clusters on Proxmox VMs. Uses [terraform-proxmox-vm](https://github.com/n2solutionsio/terraform-proxmox-vm) for VM provisioning.

## Usage

```hcl
module "k3s" {
  source = "git::https://github.com/n2solutionsio/terraform-proxmox-k3s.git?ref=v0.1.0"

  cluster_name        = "prod-k3s"
  node_name           = "proxmox-01"
  control_plane_count = 1
  worker_count        = 2
  vlan_id             = 30
  network_bridge      = "vmbr1"
  k3s_token           = var.k3s_token
  ssh_keys            = [var.ssh_public_key]
}
```

## Requirements

| Name | Version |
|------|---------|
| OpenTofu/Terraform | >= 1.6.0 |
| proxmox | ~> 0.95.0 |

## Dependencies

- [terraform-proxmox-vm](https://github.com/n2solutionsio/terraform-proxmox-vm) v0.1.0

## License

MPL-2.0
