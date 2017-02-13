output "ip-coreos-1" {
    value = "You can login with 'ssh -i ${var.ssh_key_path} core@${packet_device.coreos.coreos-1.network.0.address}'"
}
output "ip-coreos-2" {
    value = "You can login with 'ssh -i ${var.ssh_key_path} core@${packet_device.coreos.coreos-2.network.0.address}'"
}
output "ip-coreos-3" {
    value = "You can login with 'ssh -i ${var.ssh_key_path} core@${packet_device.coreos.coreos-3.network.0.address}'"
}
