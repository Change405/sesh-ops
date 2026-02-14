# Server Configuration
variable "server_names" {
  description = "List of server names to create"
  type        = list(string)
  default     = ["node-1"]
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx33"
}

variable "server_location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1"
}

variable "server_image" {
  description = "OS image for servers"
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "../session_node_key.pub"
}
