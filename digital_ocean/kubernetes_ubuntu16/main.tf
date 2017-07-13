
provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_droplet" "master" {
    image = "ubuntu-16-10-x64"
    name = "master"
    region = "${var.region}"
    size = "${var.size}"
    private_networking = true
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]
    connection {
      agent = false
      user = "root"
      type = "ssh"
      private_key = "${file("${var.ssh_key_path}")}"
      timeout = "1m"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo apt-get update",
        "sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common",
        "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - ",
        "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
        "sudo apt-get -y update",
        "sudo apt-get -y install docker-ce",
        "sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
        "sudo echo \"deb http://apt.kubernetes.io/ kubernetes-xenial main\" | sudo tee /etc/apt/sources.list.d/kubernetes.list",
        "sudo apt-get update && sudo apt-get install -y kubelet=${var.k8s_version}-00 kubeadm=${var.k8s_version}-00 kubectl=${var.k8s_version}-00 kubernetes-cni vim git",
        "kubeadm init --kubernetes-version v${var.k8s_version} --apiserver-advertise-address ${self.ipv4_address_private} --pod-network-cidr 10.244.0.0/16 --token ${var.k8s_token}",
        # "kubeadm init --kubernetes-version v${var.k8s_version} --apiserver-advertise-address ${self.ipv4_address_private} --token ${var.k8s_token}",
        "echo \"***** Setting up kubeconfig\"",
        "sudo cp /etc/kubernetes/admin.conf /root",
        "sudo chown $(id -u):$(id -g) /root/admin.conf",
        "echo \"export KUBECONFIG=/root/admin.conf\" >> /root/.bashrc",
        "echo \"alias kc=kubectl\" >> /root/.bashrc",
        "sleep 5",
        "KUBECONFIG=/root/admin.conf kubectl apply -n kube-system -f \"https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.0.0.0/16\""
      ]
    }
}


resource "digitalocean_volume" "px-vol" {
  region      = "${var.region}"
  count       = "${var.do_count}"
  name        = "${var.prefix}-px-vol-${count.index + 1}"
  size        = "${var.volsize}"
  description = "px volume"
}

resource "digitalocean_droplet" "minion" {
    depends_on = ["digitalocean_volume.px-vol"]
    image = "ubuntu-16-10-x64"
    count = "${var.do_count}"
    name = "minion-${count.index + 1}"
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
        "sudo apt-get update",
        "sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common",
        "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - ",
        "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
        "sudo apt-get -y update",
        "sudo apt-get -y install docker-ce",
        "sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
        "sudo echo \"deb http://apt.kubernetes.io/ kubernetes-xenial main\" | sudo tee /etc/apt/sources.list.d/kubernetes.list",
        "sudo apt-get update && sudo apt-get install -y kubelet=${var.k8s_version}-00 kubeadm=${var.k8s_version}-00 kubectl=${var.k8s_version}-00 kubernetes-cni vim git",
        "kubeadm join --token ${var.k8s_token} ${digitalocean_droplet.master.ipv4_address_private}:6443"
      ]
    }
}


