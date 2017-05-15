output "ip-addrs" {
   value = [ "${formatlist("ssh root@%s", "${digitalocean_droplet.centos.*.ipv4_address}")}" ]
}
