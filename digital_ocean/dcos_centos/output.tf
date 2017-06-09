output "agent-ip" {
  value = "${join(",", digitalocean_droplet.dcos_agent.*.ipv4_address)}"
}
output "agent-public-ip" {
  value = "${join(",", digitalocean_droplet.dcos_public_agent.*.ipv4_address)}"
}
output "master-ip" {
  value = "${join(",", digitalocean_droplet.dcos_master.*.ipv4_address)}"
}
output "bootstrap-ip" {
  value = "${digitalocean_droplet.dcos_bootstrap.ipv4_address}"
}

output "Use this link to access DCOS" {
  value = "http://${digitalocean_droplet.dcos_master.0.ipv4_address}/"
}
