# Main infrastructure configuration for Session Service Nodes

locals {
  project_name = "session-service-nodes"
  environment  = "production"

  common_labels = {
    project     = local.project_name
    environment = local.environment
    managed_by  = "terraform"
  }
}

# Future infrastructure resources will be added here:

# Example: SSH Key Resource
# resource "hcloud_ssh_key" "default" {
#   name       = "${local.project_name}-key"
#   public_key = file("~/.ssh/id_rsa.pub")
#   labels     = local.common_labels
# }

# Example: Server Resource
# resource "hcloud_server" "node" {
#   count       = var.server_count
#   name        = "${local.project_name}-node-${count.index + 1}"
#   server_type = var.server_type
#   location    = var.server_location
#   image       = "ubuntu-22.04"
#   ssh_keys    = [hcloud_ssh_key.default.id]
#   labels      = local.common_labels
# }

# Example: Firewall Resource
# resource "hcloud_firewall" "node_firewall" {
#   name   = "${local.project_name}-firewall"
#   labels = local.common_labels
#
#   rule {
#     direction = "in"
#     protocol  = "tcp"
#     port      = "22"
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0"
#     ]
#   }
# }
