locals {
  network_prefix    = split("/", var.network_cidr)[1]
  control_plane_ips = [for i in range(var.control_plane_count) : cidrhost(var.network_cidr, var.ip_offset + i)]
  worker_ips        = [for i in range(var.worker_count) : cidrhost(var.network_cidr, var.ip_offset + var.control_plane_count + i)]
  primary_cp_ip     = local.control_plane_ips[0]
}

resource "proxmox_virtual_environment_download_file" "cloud_image" {
  content_type        = "import"
  datastore_id        = var.cloud_image_storage
  node_name           = var.node_name
  url                 = var.cloud_image_url
  file_name           = var.cloud_image_file_name
  overwrite_unmanaged = true
}

resource "proxmox_virtual_environment_file" "cloud_init_server" {
  count        = var.control_plane_count
  content_type = "snippets"
  datastore_id = var.snippet_storage
  node_name    = var.node_name

  source_raw {
    data = templatefile("${path.module}/templates/k3s-server.yaml.tftpl", {
      k3s_version        = var.k3s_version
      k3s_token          = var.k3s_token
      cloud_init_user    = var.cloud_init_user
      ssh_keys           = var.ssh_keys
      hostname           = "${var.cluster_name}-cp-${count.index}"
      disable_components = var.disable_components
    })
    file_name = "${var.cluster_name}-k3s-server-${count.index}.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_agent" {
  count        = var.worker_count
  content_type = "snippets"
  datastore_id = var.snippet_storage
  node_name    = var.node_name

  source_raw {
    data = templatefile("${path.module}/templates/k3s-agent.yaml.tftpl", {
      k3s_version     = var.k3s_version
      k3s_token       = var.k3s_token
      server_address  = local.primary_cp_ip
      cloud_init_user = var.cloud_init_user
      ssh_keys        = var.ssh_keys
      hostname        = "${var.cluster_name}-worker-${count.index}"
    })
    file_name = "${var.cluster_name}-k3s-agent-${count.index}.yaml"
  }
}

module "control_plane" {
  source = "git::https://github.com/n2solutionsio/terraform-proxmox-vm.git?ref=v0.2.0"
  count  = var.control_plane_count

  node_name      = var.node_name
  vm_name        = "${var.cluster_name}-cp-${count.index}"
  cpu_cores      = var.control_plane_cpu
  memory         = var.control_plane_memory
  disk_size      = var.control_plane_disk_size
  disk_storage   = var.disk_storage
  import_from    = proxmox_virtual_environment_download_file.cloud_image.id
  vlan_id        = var.vlan_id
  network_bridge = var.network_bridge

  cloud_init_enabled           = true
  cloud_init_user              = var.cloud_init_user
  cloud_init_ssh_keys          = var.ssh_keys
  cloud_init_user_data_file_id = proxmox_virtual_environment_file.cloud_init_server[count.index].id
  cloud_init_ip                = "${local.control_plane_ips[count.index]}/${local.network_prefix}"
  cloud_init_gateway           = var.gateway
  cloud_init_dns               = var.dns_servers
}

module "workers" {
  source = "git::https://github.com/n2solutionsio/terraform-proxmox-vm.git?ref=v0.2.0"
  count  = var.worker_count

  node_name      = var.node_name
  vm_name        = "${var.cluster_name}-worker-${count.index}"
  cpu_cores      = var.worker_cpu
  memory         = var.worker_memory
  disk_size      = var.worker_disk_size
  disk_storage   = var.disk_storage
  import_from    = proxmox_virtual_environment_download_file.cloud_image.id
  vlan_id        = var.vlan_id
  network_bridge = var.network_bridge

  cloud_init_enabled           = true
  cloud_init_user              = var.cloud_init_user
  cloud_init_ssh_keys          = var.ssh_keys
  cloud_init_user_data_file_id = proxmox_virtual_environment_file.cloud_init_agent[count.index].id
  cloud_init_ip                = "${local.worker_ips[count.index]}/${local.network_prefix}"
  cloud_init_gateway           = var.gateway
  cloud_init_dns               = var.dns_servers

  depends_on = [module.control_plane]
}
