provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_volume" "px-vol" {
  region      = "${var.region}"
  count       = "${var.do_count}"
  name        = "${var.prefix}-px-vol-${count.index + 1}"
  size        = "${var.volsize}"
  description = "px volume"
}

resource "digitalocean_droplet" "ubuntu16" {
    depends_on = ["digitalocean_volume.px-vol"]
    image = "ubuntu-16-10-x64"
    count = "${var.do_count}"
    name = "${var.prefix}-ubuntu16-${count.index + 1}"
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
      ]
    }
}

#
# Run etcd only on the first server
#
resource "null_resource" "run-etcd" {
  depends_on = ["digitalocean_droplet.ubuntu16"]
  connection {
    user = "root"
    private_key = "${file("${var.ssh_key_path}")}"
    host = "${digitalocean_droplet.ubuntu16.0.ipv4_address}"
    agent = false
  }

  provisioner "remote-exec" {
      inline = [
        "docker run --net=host -d --name etcd-v3.1.3 --volume=/tmp/etcd-data:/etcd-data quay.io/coreos/etcd:v3.1.3 /usr/local/bin/etcd --name my-etcd-1 --data-dir /etcd-data --listen-client-urls http://0.0.0.0:2379 --advertise-client-urls http://${digitalocean_droplet.ubuntu16.0.ipv4_address_private}:2379 --listen-peer-urls http://0.0.0.0:2380 --initial-advertise-peer-urls http://${digitalocean_droplet.ubuntu16.0.ipv4_address_private}:2380 --initial-cluster my-etcd-1=http://${digitalocean_droplet.ubuntu16.0.ipv4_address_private}:2380 --initial-cluster-token my-etcd-token --initial-cluster-state new --auto-compaction-retention 1"
       ]
  }
}

#
# Run PX on all servers
#
resource "null_resource" "run-px" {
  depends_on = ["null_resource.run-etcd"]
  count = "${var.do_count}"
  connection {
    user = "root"
    private_key = "${file("${var.ssh_key_path}")}"
    host = "${element(digitalocean_droplet.ubuntu16.*.ipv4_address, count.index)}"
    agent = false
  }
   provisioner "remote-exec" {
     inline = [ "docker run --restart=always --name px -d --net=host --privileged=true -v /run/docker/plugins:/run/docker/plugins -v /var/lib/osd:/var/lib/osd:shared -v /dev:/dev -v /etc/pwx:/etc/pwx -v /opt/pwx/bin:/export_bin:shared -v /var/run/docker.sock:/var/run/docker.sock -v /var/cores:/var/cores -v /usr/src:/usr/src -v /lib/modules:/lib/modules --ipc=host portworx/px-dev -daemon -k etcd://${digitalocean_droplet.ubuntu16.0.ipv4_address_private}:2379 -c MY_CLUSTER_ID -a -f -z -d eth1 -m eth1" ]
   }
}

