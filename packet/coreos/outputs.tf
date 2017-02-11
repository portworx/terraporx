output "ip-coreos-1" {
    value = "${packet_device.coreos-1.network.0.address}"
}
