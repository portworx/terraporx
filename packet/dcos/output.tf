output "agent-ip" {
  value = "${join(",", packet_device.dcos_agent.*.network.0.address)}"
}
output "agent-public-ip" {
  value = "${join(",", packet_device.dcos_public_agent.*.network.0.address)}"
}
output "master-ip" {
  value = "${join(",", packet_device.dcos_master.*.network.0.address)}"
}
output "bootstrap-ip" {
  value = "${packet_device.dcos_bootstrap.network.0.address}"
}
output "Use this link to access DCOS" {
  value = "http://${packet_device.dcos_master.network.0.address}/"
}
