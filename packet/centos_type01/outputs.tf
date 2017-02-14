output "ip-addrs" {
   value = [ "${formatlist("ssh -i key root@%s", "${packet_device.centos7.*.network.0.address}")}" ]
} 

#   value = [ "${formatlist("ssh -i ${file(${var.ssh_key_path})} root@%s", "${packet_device.centos7.*.network.0.address}")}" ]
#   value = [ "${formatlist("ssh -i key root@%s", "${packet_device.centos7.*.network.0.address}")}" ]
#  value = ["ssh -i ${file(${var.ssh_key_path})} root@${packet_device.centos7.*.network.0.address}"]
#  records = ["${formatlist("0 0 %s", template_file.node_name.*.rendered)}"]

