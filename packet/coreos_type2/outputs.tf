output "ip-addrs" {
   value = [ "${formatlist("ssh -i key root@%s", "${packet_device.coreos.*.network.0.address}")}" ]
}
