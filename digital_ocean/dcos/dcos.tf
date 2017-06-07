provider "digitalocean" {
  token = "${var.digitalocean_token}"
}

resource "digitalocean_droplet" "dcos_bootstrap" {
  name = "${format("${var.dcos_cluster_name}-bootstrap-%02d", count.index)}"
  
  image = "coreos-stable"
  size             = "${var.boot_size}"
    ssh_keys = ["${var.ssh_key_fingerprint}"]
  connection {
    user = "core"
    private_networking = true
    private_key = "${file(var.dcos_ssh_key_path)}"
  }
  user_data     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
  region      = "${var.region}"

  provisioner "local-exec" {
    command = "rm -rf ./do-install.sh"
  }
  provisioner "local-exec" {
    command = "echo BOOTSTRAP=\"${digitalocean_droplet.dcos_bootstrap.ipv4_address}\" >> ips.txt"
  }
  provisioner "local-exec" {
    command = "echo CLUSTER_NAME=\"${var.dcos_cluster_name}\" >> ips.txt"
  }  
  provisioner "remote-exec" {
  inline = [
    "wget -q -O dcos_generate_config.sh -P $HOME ${var.dcos_installer_url}",
    "mkdir $HOME/genconf"
    ]
  }
  provisioner "local-exec" {
    command = "./make-files.sh"
  }
  provisioner "local-exec" {
    command = "sed -i -e '/^- *$/d' ./config.yaml"
  }
  provisioner "file" {
    source = "./ip-detect"
    destination = "$HOME/genconf/ip-detect"
  }
  provisioner "file" {
    source = "./config.yaml"
    destination = "$HOME/genconf/config.yaml"
  }
  provisioner "remote-exec" {
    inline = ["sudo bash $HOME/dcos_generate_config.sh",
              "docker run -d -p 4040:80 -v $HOME/genconf/serve:/usr/share/nginx/html:ro nginx 2>/dev/null",
              "docker run -d -p 2181:2181 -p 2888:2888 -p 3888:3888 --name=dcos_int_zk jplock/zookeeper 2>/dev/null"
              ]
  }
}

resource "digitalocean_droplet" "dcos_master" {
  name = "${format("${var.dcos_cluster_name}-master-%02d", count.index)}"
  image = "coreos-stable"
  size             = "${var.master_size}"

  ssh_keys = ["${var.ssh_key_fingerprint}"]

  count         = "${var.dcos_master_count}"
  user_data     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
  region      = "${var.region}"
    private_networking = true
  connection {
    user = "core"
    private_key = "${file(var.dcos_ssh_key_path)}"
  }
  provisioner "local-exec" {
    command = "rm -rf ./do-install.sh"
  }
  provisioner "local-exec" {
    command = "echo ${format("MASTER_%02d", count.index)}=\"${self.ipv4_address}\" >> ips.txt"
  }
  provisioner "local-exec" {
    command = "while [ ! -f ./do-install.sh ]; do sleep 1; done"
  }
  provisioner "file" {
    source = "./do-install.sh"
    destination = "/tmp/do-install.sh"
  }
  provisioner "remote-exec" {
    inline = "bash /tmp/do-install.sh master"
  }
}

resource "digitalocean_volume" "px-vol" {
  region      = "${var.region}"
  count       = "${var.dcos_agent_count}"
  name        = "${var.dcos_cluster_name}-px-vol-${count.index + 1}"
  size        = "${var.volsize}"
  description = "portworx volume"
}

resource "digitalocean_droplet" "dcos_agent" {
  name = "${format("${var.dcos_cluster_name}-agent-%02d", count.index)}"
  depends_on = ["digitalocean_droplet.dcos_bootstrap", "digitalocean_volume.px-vol"]
  image = "coreos-stable"
  size          = "${var.agent_size}"
  count         = "${var.dcos_agent_count}"
  volume_ids = ["${element("${digitalocean_volume.px-vol.*.id}",count.index)}"]
  user_data     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
  region      = "${var.region}"
    private_networking = true
  ssh_keys = ["${var.ssh_key_fingerprint}"]
  connection {
    user = "core"
    private_key = "${file(var.dcos_ssh_key_path)}"
  }
  provisioner "local-exec" {
    command = "while [ ! -f ./do-install.sh ]; do sleep 1; done"
  }
  provisioner "file" {
    source = "do-install.sh"
    destination = "/tmp/do-install.sh"
  }
  provisioner "remote-exec" {
    inline = "bash /tmp/do-install.sh slave"
  }
}


resource "digitalocean_droplet" "dcos_public_agent" {
  name = "${format("${var.dcos_cluster_name}-public-agent-%02d", count.index)}"
  depends_on = ["digitalocean_droplet.dcos_bootstrap"]
  image = "coreos-stable"
  size          = "${var.agent_size}"
  count         = "${var.dcos_public_agent_count}"
  user_data     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
  region      = "${var.region}"
    private_networking = true
  ssh_keys = ["${var.ssh_key_fingerprint}"]
  connection {
    user = "core"
    private_key = "${file(var.dcos_ssh_key_path)}"
  }
  provisioner "local-exec" {
    command = "while [ ! -f ./do-install.sh ]; do sleep 1; done"
  }
  provisioner "file" {
    source = "do-install.sh"
    destination = "/tmp/do-install.sh"
  }
  provisioner "remote-exec" {
    inline = "bash /tmp/do-install.sh slave_public"
  }
}
