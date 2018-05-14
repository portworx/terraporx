
provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
}

locals {
     clusterid = "${uuid()}"
}

variable d_eth_if { default = "ens4" }
variable m_eth_if { default = "ens4" }

module "portworx" {
   source = "github.com/portworx/terraform-portworx-portworx-instance"
   clusterID = "${local.clusterid}"
   data_if = "${var.d_eth_if}"
   mgmt_if = "${var.m_eth_if}"
   device_args = "-s /dev/sdb"
   force_use = "true"
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

resource "google_compute_disk" "px-disk" {
  count = "${var.px-count}"
  name = "${var.prefix}-px-disk-${count.index}"
  type = "pd-ssd"
  zone = "${var.region_zone}"
  size = "${var.volsize}"
}

resource "google_compute_instance" "px-node" {
  count = "${var.px-count}"

  name         = "${var.prefix}-${count.index}"
  machine_type = "${var.machine_type}"
  zone         = "${var.region_zone}"

  boot_disk {
    initialize_params {
        image = "ubuntu-1604-xenial-v20170328"
    }
  }

  attached_disk {
    source      = "${element(google_compute_disk.px-disk.*.self_link, count.index)}"
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral
    }
  }

     metadata {
       ssh-keys = "root:${file("${var.public_key_path}")}"
     }


      provisioner "remote-exec" {
        connection {
          type        = "ssh"
          user        = "root"
          private_key = "${file("${var.private_key_path}")}"
          agent       = false
       }
 
      inline = [
        "sudo apt-get update",
        "sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common",
        "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - ",
        "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
        "sudo apt-get -y update",
        "sudo apt-get -y install docker-ce",
        "sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
         "${module.portworx.get_px_cmd}"
      ]
    }
}
