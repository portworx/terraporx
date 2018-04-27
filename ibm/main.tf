provider "ibm" {}

# provider "ibm" {
#   bluemix_api_key =    "${var.ibm_bx_api_key}"    # See https://console.bluemix.net/iam#/apikeys   (BM_API_KEY)
#   softlayer_username = "${var.ibm_sl_username}"   # See https://control.bluemix.net/account/user/profile  API Username  (SL_USERNAME)
#   softlayer_api_key  = "${var.ibm_sl_api_key}"    # See https://control.bluemix.net/account/user/profile  Authentication Key (SL_API_KEY)
# }

data "ibm_compute_ssh_key" "public_key" {
    label = "jeff"
}

locals {
      clusterid = "${uuid()}"
}

module "portworx" {
   source = "github.com/portworx/terraform-portworx-portworx-instance"
   clusterID = "${local.clusterid}"
   data_if = "${var.d_eth_if}"
   mgmt_if = "${var.m_eth_if}"
   device_args = "-a"
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

resource "ibm_compute_vm_instance" "my-vm" {
  hostname          = "jeff1"
  domain            = "example.com"
  ssh_key_ids = ["${data.ibm_compute_ssh_key.public_key.id}"]
  os_reference_code = "CENTOS_7_64"
  datacenter        = "dal13"
  hourly_billing = true
  disks = [ 25, 25 ]
  local_disk = true
  network_speed     = 10
  cores             = 1
  memory            = 1024

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
