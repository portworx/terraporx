
provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
}

resource "google_compute_disk" "px-disk" {
  count = "${var.minion-count}"
  name = "${var.prefix}-px-disk-${count.index}"
  type = "pd-ssd"
  zone = "${var.region_zone}"
  size = "${var.volsize}"
}

resource "google_compute_disk" "px-master-disk" {
  name = "${var.prefix}-px-master-disk"
  type = "pd-ssd"
  zone = "${var.region_zone}"
  size = "${var.volsize}"
}

resource "google_compute_instance" "k8s_master" {

  name         = "${var.prefix}-k8s-master"
  machine_type = "${var.machine_type}"
  zone         = "${var.region_zone}"

  boot_disk {
    initialize_params {
        image = "ubuntu-os-cloud/ubuntu-1610-yakkety-v20170619a"
    }
  }

  attached_disk {
        source      = "${google_compute_disk.px-master-disk.0.self_link}"
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
        "sudo echo \"deb http://apt.kubernetes.io/ kubernetes-xenial main\" | sudo tee /etc/apt/sources.list.d/kubernetes.list",
        "sudo apt-get update && sudo apt-get install -y kubelet=${var.k8s_version} kubeadm=${var.k8s_version} kubectl=${var.k8s_version} kubernetes-cni vim git",
        "kubeadm init --kubernetes-version v${var.k8s_init_version} --apiserver-advertise-address ${self.network_interface.0.address} --pod-network-cidr 10.244.0.0/16 --token ${var.k8s_token}",
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





resource "google_compute_instance" "k8s_minion" {
  count = "${var.minion-count}"

  name         = "${var.prefix}-k8s-${count.index}"
  machine_type = "${var.machine_type}"
  zone         = "${var.region_zone}"

  boot_disk {
    initialize_params {
        image = "ubuntu-os-cloud/ubuntu-1610-yakkety-v20170619a"
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
        "sudo echo \"deb http://apt.kubernetes.io/ kubernetes-xenial main\" | sudo tee /etc/apt/sources.list.d/kubernetes.list",
        "sudo apt-get update && sudo apt-get install -y kubelet=${var.k8s_version} kubeadm=${var.k8s_version} kubectl=${var.k8s_version} kubernetes-cni vim git",
        "kubeadm join --token ${var.k8s_token} ${google_compute_instance.k8s_master.network_interface.0.address}:6443"
      ]
    }
}




