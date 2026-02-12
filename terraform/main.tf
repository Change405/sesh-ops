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

# SSH Key
resource "hcloud_ssh_key" "default" {
  name       = "${local.project_name}-key"
  public_key = file(var.ssh_public_key_path)
  labels     = local.common_labels
}

# Firewall for Session Nodes
resource "hcloud_firewall" "session_node" {
  name   = "${local.project_name}-firewall"
  labels = local.common_labels

  # SSH
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Storage Server to Storage Server (TCP/UDP)
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22020"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "22020"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Session Client to Storage Server
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22021"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Blockchain syncing
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22022"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Session Node to Session Node
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22025"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Lokinet router data
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "1090"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Session Router data
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "1190"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

# Session Service Node Servers
resource "hcloud_server" "node" {
  for_each = toset(var.server_names)

  name         = "${local.project_name}-${each.value}"
  server_type  = var.server_type
  location     = var.server_location
  image        = var.server_image
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.session_node.id]
  labels       = local.common_labels
}
