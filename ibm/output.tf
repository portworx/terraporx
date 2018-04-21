output "public-ip-addrs" {
   value = [ "${ibm_compute_vm_instance.my-vm.ipv4_address}" ]
}

output "private-ip-addrs" {
   value = [ "${ibm_compute_vm_instance.my-vm.ipv4_address_private}" ]
}
