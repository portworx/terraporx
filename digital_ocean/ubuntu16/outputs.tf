output "ip-addrs" {
   value = [ "${formatlist("ssh root@%s", "${digitalocean_droplet.ubuntu16.*.ipv4_address}")}" ]
}
