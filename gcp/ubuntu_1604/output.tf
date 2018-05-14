output "ip-addrs" {
  value = [ "${formatlist("ssh root@%s", "${google_compute_instance.px-node.*.network_interface.0.access_config.0.assigned_nat_ip}")}" ]
}
