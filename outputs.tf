output "control_plane_vm_ids" {
  description = "VM IDs of control plane nodes"
  value       = module.control_plane[*].vm_id
}

output "control_plane_ips" {
  description = "Static IPv4 addresses of control plane nodes"
  value       = local.control_plane_ips
}

output "worker_vm_ids" {
  description = "VM IDs of worker nodes"
  value       = module.workers[*].vm_id
}

output "worker_ips" {
  description = "Static IPv4 addresses of worker nodes"
  value       = local.worker_ips
}

output "kubeconfig_command" {
  description = "Command to retrieve kubeconfig from the first control plane node"
  value       = "ssh ${var.cloud_init_user}@${local.primary_cp_ip} 'sudo cat /etc/rancher/k3s/k3s.yaml'"
}
