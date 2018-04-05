provider "packet" {
  auth_token = "${var.auth_token}"
}

resource "packet_project" "myproject" {
      name = "${var.projectname}"
}

variable d_eth_if { default = "bond0:0" }
variable m_eth_if { default = "bond0:0" }

resource "packet_device" "packet_server" {
      count            = "${var.packet_count}"
      hostname         = "${var.hostname}-${count.index + 1}"
      plan             = "${var.packet_device_plan}"
      facility         = "${var.facility}"
      operating_system = "${var.packet_os}"
      billing_cycle    = "hourly"
      project_id       = "${packet_project.myproject.id}"
      connection {
         user = "root"
         private_key = "${file("${var.ssh_key_path}")}"
         agent = false
      }

      provisioner "remote-exec" {
         inline = [
            "curl -fsSL https://get.docker.io | sh"
        ]
     }
}

resource "packet_volume" "px_volume" {
      count = "${var.packet_count}"
      plan = "${var.packet_storage_plan}"
      billing_cycle = "hourly"
      size = "${var.packet_volume_size}"
      project_id = "${packet_project.myproject.id}"
      facility = "${var.facility}"
      snapshot_policies = { snapshot_frequency = "1day", snapshot_count = 7 }
}

resource "packet_volume_attachment" "px_volume_attachment" {
      count = "${var.packet_count}"
      device_id = "${element(packet_device.packet_server.*.id,count.index)}"
      volume_id = "${element(packet_volume.px_volume.*.id,count.index)}"
}

locals {
      clusterid = "${uuid()}"
}

resource "null_resource" "run-px" {
  count = "${var.packet_count}"
  connection {
    user = "root"
    private_key = "${file("${var.ssh_key_path}")}"
    host = "${element(packet_device.packet_server.*.access_public_ipv4, count.index)}"
    agent = false
  }
   provisioner "remote-exec" {
     inline = [ "/usr/bin/packet-block-storage-attach",
                "ls /dev/mapper/volume-* > /tmp/pxvol",
                "curl -fsSL https://get.portworx.com | sh -s -- -s `cat /tmp/pxvol` -c ${local.clusterid} -d ${var.d_eth_if} -m ${var.m_eth_if}" ]
   }
}

