resource "proxmox_virtual_environment_file" "cloud_init_server" {
  content_type = "snippets"
  datastore_id = var.snippet_storage
  node_name    = var.node_name

  source_raw {
    data = templatefile("${path.module}/templates/k3s-server.yaml.tftpl", {
      k3s_version = var.k3s_version
      k3s_token   = var.k3s_token
    })
    file_name = "${var.cluster_name}-k3s-server.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_agent" {
  content_type = "snippets"
  datastore_id = var.snippet_storage
  node_name    = var.node_name

  source_raw {
    data = templatefile("${path.module}/templates/k3s-agent.yaml.tftpl", {
      k3s_version    = var.k3s_version
      k3s_token      = var.k3s_token
      server_address = "$${server_address}"
    })
    file_name = "${var.cluster_name}-k3s-agent.yaml"
  }
}

module "control_plane" {
  source = "git::https://github.com/n2solutionsio/terraform-proxmox-vm.git?ref=v0.1.0"
  count  = var.control_plane_count

  node_name      = var.node_name
  vm_name        = "${var.cluster_name}-cp-${count.index}"
  cpu_cores      = var.control_plane_cpu
  memory         = var.control_plane_memory
  disk_size      = var.control_plane_disk_size
  disk_storage   = var.disk_storage
  vlan_id        = var.vlan_id
  network_bridge = var.network_bridge

  cloud_init_enabled           = true
  cloud_init_user              = var.cloud_init_user
  cloud_init_ssh_keys          = var.ssh_keys
  cloud_init_user_data_file_id = proxmox_virtual_environment_file.cloud_init_server.id
}

module "workers" {
  source = "git::https://github.com/n2solutionsio/terraform-proxmox-vm.git?ref=v0.1.0"
  count  = var.worker_count

  node_name      = var.node_name
  vm_name        = "${var.cluster_name}-worker-${count.index}"
  cpu_cores      = var.worker_cpu
  memory         = var.worker_memory
  disk_size      = var.worker_disk_size
  disk_storage   = var.disk_storage
  vlan_id        = var.vlan_id
  network_bridge = var.network_bridge

  cloud_init_enabled           = true
  cloud_init_user              = var.cloud_init_user
  cloud_init_ssh_keys          = var.ssh_keys
  cloud_init_user_data_file_id = proxmox_virtual_environment_file.cloud_init_agent.id

  depends_on = [module.control_plane]
}
