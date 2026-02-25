variable "cluster_name" {
  description = "Name prefix for the k3s cluster resources"
  type        = string
}

variable "node_name" {
  description = "Proxmox node to create VMs on"
  type        = string
}

variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.control_plane_count >= 1
    error_message = "At least 1 control plane node is required."
  }
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.worker_count >= 0
    error_message = "Worker count must be 0 or more."
  }
}

variable "control_plane_cpu" {
  description = "CPU cores for control plane nodes"
  type        = number
  default     = 2
}

variable "control_plane_memory" {
  description = "Memory in MB for control plane nodes"
  type        = number
  default     = 4096
}

variable "control_plane_disk_size" {
  description = "Disk size in GB for control plane nodes"
  type        = number
  default     = 30
}

variable "worker_cpu" {
  description = "CPU cores for worker nodes"
  type        = number
  default     = 2
}

variable "worker_memory" {
  description = "Memory in MB for worker nodes"
  type        = number
  default     = 4096
}

variable "worker_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 50
}

variable "disk_storage" {
  description = "Storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "vlan_id" {
  description = "VLAN ID for the cluster network"
  type        = number

  validation {
    condition     = var.vlan_id >= 1 && var.vlan_id <= 4094
    error_message = "VLAN ID must be between 1 and 4094."
  }
}

variable "network_bridge" {
  description = "Network bridge to attach to"
  type        = string
  default     = "vmbr0"
}

variable "k3s_version" {
  description = "k3s version to install"
  type        = string
  default     = "v1.31.4+k3s1"
}

variable "k3s_token" {
  description = "Shared secret for k3s cluster join"
  type        = string
  sensitive   = true
}

variable "ssh_keys" {
  description = "SSH public keys for VM access"
  type        = list(string)
  default     = []
  sensitive   = true
}

variable "cloud_init_user" {
  description = "Default user for cloud-init"
  type        = string
  default     = "ubuntu"
}

variable "snippet_storage" {
  description = "Proxmox storage for cloud-init snippets"
  type        = string
  default     = "local"
}

variable "cloud_image_url" {
  description = "URL for the cloud image to download"
  type        = string
  default     = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
}

variable "cloud_image_storage" {
  description = "Proxmox storage for the cloud image download"
  type        = string
  default     = "local"
}

variable "cloud_image_file_name" {
  description = "File name for the downloaded cloud image (must end in .qcow2 for import)"
  type        = string
  default     = "ubuntu-24.04-server-cloudimg-amd64.qcow2"
}

variable "network_cidr" {
  description = "CIDR block for the cluster network (e.g., 10.30.30.0/24)"
  type        = string
}

variable "ip_offset" {
  description = "Starting host number for IP assignment (e.g., 10 means first VM gets .10)"
  type        = number
  default     = 10
}

variable "gateway" {
  description = "Default gateway for VMs"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers for VMs"
  type        = list(string)
  default     = []
}
