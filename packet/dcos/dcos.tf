provider "packet" {
  auth_token = "${var.packet_api_key}"
}

resource "packet_device" "dcos_bootstrap" {
  hostname = "${format("${var.dcos_cluster_name}-bootstrap-%02d", count.index)}"

  operating_system = "coreos_stable"
  plan             = "${var.packet_boot_type}"
  connection {
    user = "core"
    private_key = "${file("${var.dcos_ssh_key_path}")}"
  }
  user_data     = "#cloud-config\n\nmanage_etc_hosts: \"localhost\"\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
  facility      = "${var.packet_facility}"
  project_id    = "${var.packet_project_id}"
  billing_cycle = "hourly"
  provisioner "local-exec" {
    command = "rm -rf ./do-install.sh"
  }
  provisioner "local-exec" {
    command = "echo BOOTSTRAP=\"${packet_device.dcos_bootstrap.network.0.address}\" >> ips.txt"
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

resource "packet_device" "dcos_master" {
  hostname = "${format("${var.dcos_cluster_name}-master-%02d", count.index)}"
  operating_system = "coreos_stable"
  plan             = "${var.packet_master_type}"

  count         = "${var.dcos_master_count}"
  user_data     = "#cloud-config\n\nmanage_etc_hosts: \"localhost\"\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
  facility      = "${var.packet_facility}"
  project_id    = "${var.packet_project_id}"
  billing_cycle = "hourly"
  connection {
    user = "core"
    private_key = "${file("${var.dcos_ssh_key_path}")}"
  }
  provisioner "local-exec" {
    command = "rm -rf ./do-install.sh"
  }
  provisioner "local-exec" {
    command = "echo ${format("MASTER_%02d", count.index)}=\"${self.network.0.address}\" >> ips.txt"
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

resource "packet_device" "dcos_agent" {
  hostname = "${format("${var.dcos_cluster_name}-agent-%02d", count.index)}"
  depends_on = ["packet_device.dcos_bootstrap"]
  operating_system = "coreos_stable"
  plan             = "${var.packet_agent_type}"

  count         = "${var.dcos_agent_count}"
  user_data     = "#cloud-config\n\nmanage_etc_hosts: \"localhost\"\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
  facility      = "${var.packet_facility}"
  project_id    = "${var.packet_project_id}"
  billing_cycle = "hourly"
  connection {
    user = "core"
    private_key = "${file("${var.dcos_ssh_key_path}")}"
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


resource "packet_device" "dcos_public_agent" {
  hostname = "${format("${var.dcos_cluster_name}-public-agent-%02d", count.index)}"
  depends_on = ["packet_device.dcos_bootstrap"]
  operating_system = "coreos_stable"
  plan             = "${var.packet_agent_type}"

  count         = "${var.dcos_public_agent_count}"
  user_data     = "#cloud-config\n\nmanage_etc_hosts: \"localhost\"\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
  facility      = "${var.packet_facility}"
  project_id    = "${var.packet_project_id}"
  billing_cycle = "hourly"
  connection {
    user = "core"
    private_key = "${file("${var.dcos_ssh_key_path}")}"
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
