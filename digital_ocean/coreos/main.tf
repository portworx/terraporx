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
   kvdb =  "etcd:http://127.0.0.1:2379" 
   data_if = "${var.d_eth_if}"
   mgmt_if = "${var.m_eth_if}"
   device_args = "-s /dev/sda"
   # force_use = "true"
   # zero_storage = "true"
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

resource "digitalocean_droplet" "coreos" {
    depends_on = ["digitalocean_volume.px-vol"]
    image = "coreos-stable"
    count = "${var.do_count}"
    name = "${var.prefix}-coreos-${count.index + 1}"
    region = "${var.region}"
    size = "${var.size}"
    private_networking = true
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]
    volume_ids = ["${element("${digitalocean_volume.px-vol.*.id}",count.index)}"]
    user_data = <<EOF
#cloud-config
coreos:
   update:
        reboot-strategy: off
   etcd2:
       discovery: "${var.etcd_discovery_url}"
       advertise-client-urls: http://$private_ipv4:2379
       initial-advertise-peer-urls: http://$private_ipv4:2380
       listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
       listen-peer-urls: http://$private_ipv4:2380
   units:
       - name: etcd2.service
         command: start
EOF
    connection {
      agent = false
      user = "core"
      type = "ssh"
      private_key = "${file("${var.ssh_key_path}")}"
      timeout = "1m"
    }
    provisioner "remote-exec" {
       inline = [
         "sudo systemctl enable etcd-member.service",
         "sudo systemctl start etcd-member.service",
         "sudo ${module.portworx.get_px_cmd}"

       ]
   }
}
