# Hetzner Cloud Configuration
variable "hcloud_token" {
  description = "Hetzner Cloud API token (set via HCLOUD_TOKEN environment variable)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.hcloud_token) > 0
    error_message = "Hetzner Cloud token must be provided via TF_VAR_hcloud_token or HCLOUD_TOKEN environment variable"
  }
}

# Future variables for server configuration will be added here:
# - server_type (e.g., cx21, cx31)
# - server_count
# - server_location (e.g., nbg1, fsn1, hel1)
# - ssh_key_name
# - firewall_rules
