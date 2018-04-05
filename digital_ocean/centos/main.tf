provider "digitalocean" {
  token = "${var.do_token}"
}

variable d_eth_if { default = "eth1" }
variable m_eth_if { default = "eth1" }

resource "digitalocean_volume" "px-vol" {
  region      = "${var.region}"
  count       = "${var.do_count}"
  name        = "${var.prefix}-px-vol-${count.index + 1}"
  size        = "${var.volsize}"
  description = "px volume"
}

resource "digitalocean_droplet" "centos" {
    depends_on = ["digitalocean_volume.px-vol"]
    image = "centos-7-x64"
    count = "${var.do_count}"
    name = "${var.prefix}-centos-${count.index + 1}"
    region = "${var.region}"
    size = "${var.size}"
    private_networking = true
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]
    volume_ids = ["${element("${digitalocean_volume.px-vol.*.id}",count.index)}"]
    connection {
      agent = false
      user = "root"
      type = "ssh"
      private_key = "${file("${var.ssh_key_path}")}"
      timeout = "1m"
    }

     provisioner "remote-exec" {
       inline = [
         "yum install -y yum-utils",
         "yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
         "yum makecache fast",
         "yum -y install docker-ce",
         "systemctl enable docker",
         "systemctl start docker"
       ]
     }
}


locals {
      clusterid = "${uuid()}"
}

#
# Run PX on all servers
#
resource "null_resource" "run-px" {

  count = "${var.do_count}"
  connection {
    user = "root"
    private_key = "${file("${var.ssh_key_path}")}"
    host = "${element(digitalocean_droplet.centos.*.ipv4_address, count.index)}"
    agent = false
  }
   provisioner "remote-exec" {
     inline = [ "curl -fsSL https://get.portworx.com | sh -s -- -a -f -z -c ${local.clusterid} -d ${var.d_eth_if} -m ${var.m_eth_if}" ]
   }
}

