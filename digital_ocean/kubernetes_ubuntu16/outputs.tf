output "ip-addrs" {
   value = [ "${format("ssh root@%s", "${digitalocean_droplet.master.ipv4_address}")}" ]
   value = [ "${formatlist("ssh root@%s", "${digitalocean_droplet.minion.*.ipv4_address}")}" ]
}
