output "ip-centos-1" {
    value = "${packet_device.centos7-1.network.0.address}"
}
output "ip-centos-2" {
    value = "${packet_device.centos7-2.network.0.address}"
}
output "ip-centos-3" {
    value = "${packet_device.centos7-3.network.0.address}"
}
