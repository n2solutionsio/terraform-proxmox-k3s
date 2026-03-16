mock_provider "proxmox" {}

override_resource {
  target = proxmox_virtual_environment_file.cloud_init_server
  values = {
    id = "local:snippets/test-k3s-k3s-server.yaml"
  }
}

override_resource {
  target = proxmox_virtual_environment_file.cloud_init_agent
  values = {
    id = "local:snippets/test-k3s-k3s-agent.yaml"
  }
}

variables {
  cluster_name        = "test-k3s"
  node_name           = "proxmox-01"
  control_plane_count = 1
  worker_count        = 2
  vlan_id             = 30
  network_bridge      = "vmbr1"
  k3s_token           = "test-token-12345"
  ssh_keys            = ["ssh-ed25519 AAAA... test@example"]
  network_cidr        = "10.30.30.0/24"
  gateway             = "10.30.30.1"
}

run "control_plane_count" {
  command = plan

  assert {
    condition     = length(module.control_plane) == 1
    error_message = "Should create 1 control plane node"
  }
}

run "worker_count" {
  command = plan

  assert {
    condition     = length(module.workers) == 2
    error_message = "Should create 2 worker nodes"
  }
}

run "naming_convention" {
  command = plan

  assert {
    condition     = proxmox_virtual_environment_file.cloud_init_server[0].source_raw[0].file_name == "test-k3s-k3s-server-0.yaml"
    error_message = "Server cloud-init snippet should use cluster name prefix"
  }

  assert {
    condition     = proxmox_virtual_environment_file.cloud_init_agent[0].source_raw[0].file_name == "test-k3s-k3s-agent-0.yaml"
    error_message = "Agent cloud-init snippet should use cluster name prefix"
  }
}

run "cloud_init_snippet_types" {
  command = plan

  assert {
    condition     = proxmox_virtual_environment_file.cloud_init_server[0].content_type == "snippets"
    error_message = "Server cloud-init should be a snippet"
  }

  assert {
    condition     = proxmox_virtual_environment_file.cloud_init_agent[0].content_type == "snippets"
    error_message = "Agent cloud-init should be a snippet"
  }
}
