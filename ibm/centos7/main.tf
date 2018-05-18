provider "ibm" {}

# provider "ibm" {
#   bluemix_api_key =    "${var.ibm_bx_api_key}"    # See https://console.bluemix.net/iam#/apikeys   (BM_API_KEY)
#   softlayer_username = "${var.ibm_sl_username}"   # See https://control.bluemix.net/account/user/profile  API Username  (SL_USERNAME)
#   softlayer_api_key  = "${var.ibm_sl_api_key}"    # See https://control.bluemix.net/account/user/profile  Authentication Key (SL_API_KEY)
# }

data "ibm_compute_ssh_key" "public_key" {
    label = "jeff"
}


resource "ibm_compute_vm_instance" "k8s_master" {
  count             = "${var.ibm_k8s_master_count}"
  hostname          = "${var.basename}-master-${count.index + 1}"
  domain            = "example.com"
  ssh_key_ids = ["${data.ibm_compute_ssh_key.public_key.id}"]
  os_reference_code = "CENTOS_7_64"
  datacenter        = "${var.ibm_datacenter}"
  hourly_billing = true
  # disk sizes : 10, 20, 25, 30, 40, 50, 75, 100, 125, 150, 175, 200, 250, 300, 350, 400, 500, 750, 1000, 1500, 2000
  # disks = [ 25, 25 ]
  local_disk = true
  network_speed     = 10
  cores             = "${var.ibm_cores}"
  memory            = "${var.ibm_memory}"

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
    #         "docker run --net=host -d --name etcd-v3.1.3 --volume=/tmp/etcd-data:/etcd-data quay.io/coreos/etcd:v3.1.3 /usr/local/bin/etcd --name my-etcd-1 --data-dir /etcd-data --listen-client-urls http://0.0.0.0:2379 --advertise-client-urls http://${ibm_compute_vm_instance.k8s_master.0.ipv4_address_private}:2379 --listen-peer-urls http://0.0.0.0:2380 --initial-advertise-peer-urls http://${ibm_compute_vm_instance.k8s_master.0.ipv4_address_private}:2380 --initial-cluster my-etcd-1=http://${ibm_compute_vm_instance.k8s_master.0.ipv4_address_private}:2380 --initial-cluster-token my-etcd-token --initial-cluster-state new --auto-compaction-retention 1"
   #      "${module.portworx.get_px_cmd}"
       ]
  }
}

locals {
      clusterid = "${uuid()}"
}

module "portworx" {
   source = "github.com/portworx/terraform-portworx-portworx-instance"
   clusterID = "${local.clusterid}"
   data_if = "${var.d_eth_if}"
   mgmt_if = "${var.m_eth_if}"
#   kvdb = "{ etcd:http://${ibm_compute_vm_instance.k8s_master.0.ipv4_address_private}:2379 }"
   device_args = "-a"
   force_use = "true"
   # zero_storage = "true"
   # journal_dev { default = "" }
   # scheduler { default = ""}
   # token { default = "" }
   # zero_storage { default = "" }
   # env_list { default = "" }
   # secret_type { default = "" }
   # cluster_secret_key" { default = "" }
}

resource "ibm_compute_vm_instance" "k8s_agent" {
  depends_on        = [ "ibm_compute_vm_instance.k8s_master" ]
  count             = "${var.ibm_k8s_agent_count}"
  hostname          = "${var.basename}-${count.index + 1}"
  domain            = "example.com"
  ssh_key_ids = ["${data.ibm_compute_ssh_key.public_key.id}"]
  os_reference_code = "CENTOS_7_64"
  datacenter        = "${var.ibm_datacenter}"
  hourly_billing = true
  # disk sizes : 10, 20, 25, 30, 40, 50, 75, 100, 125, 150, 175, 200, 250, 300, 350, 400, 500, 750, 1000, 1500, 2000
  disks = [ 25, 25 ]
  local_disk = true
  network_speed     = 10
  cores             = "${var.ibm_cores}"
  memory            = "${var.ibm_memory}"

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
         # "${module.portworx.get_px_cmd}"
       ]
  }
}


