output "master-public-ip-addrs" {
   value = [ "${formatlist("ssh root@%s", "${ibm_compute_vm_instance.k8s_master.*.ipv4_address}")}" ]
}

output "master-private-ip-addrs" {
   value = [ "${formatlist("private addr: @%s", "${ibm_compute_vm_instance.k8s_master.*.ipv4_address_private}")}" ]
}

output "agent-public-ip-addrs" {
   value = [ "${formatlist("ssh root@%s", "${ibm_compute_vm_instance.k8s_agent.*.ipv4_address}")}" ]
}

output "agent-private-ip-addrs" {
   value = [ "${formatlist("private addr: @%s", "${ibm_compute_vm_instance.k8s_agent.*.ipv4_address_private}")}" ]
}
