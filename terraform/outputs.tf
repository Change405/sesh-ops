# Terraform Outputs

output "server_ips" {
  description = "Public IP addresses of Session service nodes"
  value = {
    for name, server in hcloud_server.node : name => server.ipv4_address
  }
}

output "server_details" {
  description = "Detailed information about Session service nodes"
  value = {
    for name, server in hcloud_server.node : name => {
      ip       = server.ipv4_address
      ipv6     = server.ipv6_address
      location = server.location
      status   = server.status
    }
  }
}
