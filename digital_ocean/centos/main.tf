provider "digitalocean" {
  token = "${var.do_token}"
}

variable d_eth_if { default = "eth1" }
variable m_eth_if { default = "eth1" }

locals {
      clusterid = "${uuid()}"
}

module "portworx" {
   source = "github.com/portworx/terraform-portworx-portworx-instance"
   clusterID = "${local.clusterid}"
   data_if = "${var.d_eth_if}"
   mgmt_if = "${var.m_eth_if}"
   device_args = "-s /dev/sda"
   # force_use = "true"
   # zero_storage = "true"
   # kvdb   { default = "" }
   # journal_dev { default = "" }
   # scheduler { default = ""}
   # token { default = "" }
   # zero_storage { default = "" }
   # env_list { default = "" }
   # secret_type { default = "" }
   # cluster_secret_key" { default = "" }
}
  
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
         "curl -fsSL https://get.docker.com | sh",
         "systemctl enable docker",
         "systemctl start docker",
         "${module.portworx.get_px_cmd}"
       ]
     }
}

