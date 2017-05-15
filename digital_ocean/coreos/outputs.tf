output "ip-addrs" {
   value = [ "${formatlist("ssh core@%s", "${digitalocean_droplet.coreos.*.ipv4_address}")}" ]
}
