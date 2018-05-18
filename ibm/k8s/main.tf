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
  datacenter        = "dal13"
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

  provisioner "file" {
       source      = "scripts/install-docker-k8s.sh"
       destination = "/tmp/install-docker-k8s.sh"
  }

  provisioner "remote-exec" {
       inline = [
         "bash /tmp/install-docker-k8s.sh",
         "swapoff -a",
         "sudo yum -y update && sudo yum install -y kubelet kubeadm kubectl kubernetes-cni vim git",
         "kubeadm init --apiserver-advertise-address ${ibm_compute_vm_instance.k8s_master.0.ipv4_address_private} --pod-network-cidr 10.244.0.0/16 --token 8c2350.f55343444a6ffc46",
         "sudo cp /etc/kubernetes/admin.conf $HOME/",
         "sudo chown $(id -u):$(id -g) $HOME/admin.conf",
         "echo \"export KUBECONFIG=$HOME/admin.conf\" >> $HOME/.bashrc",
         "curl -O https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml && KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f kube-flannel.yml",
         "curl -O https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml && KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f kube-flannel-rbac.yml",
         "KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -n kube-system -f \"https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')\""
       ]
  }
}

resource "ibm_compute_vm_instance" "k8s_agent" {
  depends_on        = [ "ibm_compute_vm_instance.k8s_master" ]
  count             = "${var.ibm_k8s_agent_count}"
  hostname          = "${var.basename}-${count.index + 1}"
  domain            = "example.com"
  ssh_key_ids = ["${data.ibm_compute_ssh_key.public_key.id}"]
  os_reference_code = "CENTOS_7_64"
  datacenter        = "dal13"
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

  provisioner "file" {
       source      = "scripts/install-docker-k8s.sh"
       destination = "/tmp/install-docker-k8s.sh"
   }

  provisioner "remote-exec" {
       inline = [
         "bash /tmp/install-docker-k8s.sh",
         "swapoff -a",
         "sudo yum -y update && sudo yum install -y kubelet kubeadm kubectl kubernetes-cni vim git",
         "kubeadm join ${ibm_compute_vm_instance.k8s_master.0.ipv4_address_private}:6443 --token 8c2350.f55343444a6ffc46 --discovery-token-unsafe-skip-ca-verification"
       ]
  }
}


