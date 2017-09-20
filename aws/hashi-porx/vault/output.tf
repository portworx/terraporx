output "vault_ips" { 
      value = "${aws_instance.vault.*.public_ip}"
}
