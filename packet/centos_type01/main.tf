provider "packet" {
  auth_token = "${var.packet_api_key}"
}

# Additional non-root volume needed for Portworx
resource "packet_volume" "px-tf-centos-volume" {
    count = "${var.packet_count}"
    description = "px-tf-centos-volume-${count.index}"
    facility = "${var.packet_facility}"
    project_id = "${var.packet_project_id}"
    plan = "${var.packet_storage_plan}"
    size = "${var.packet_volume_size}"
    billing_cycle = "hourly"
    snapshot_policies = { snapshot_frequency = "1day", snapshot_count = 7 }
    snapshot_policies = { snapshot_frequency = "1month", snapshot_count = 6 }
}

resource "packet_device" "centos7" {
  count = "${var.packet_count}"
  hostname = "${var.packet_server_hostname}-${count.index}"
  operating_system = "centos_7"
  plan          = "baremetal_0"
  facility      = "${var.packet_facility}"
  project_id    = "${var.packet_project_id}"
  billing_cycle = "hourly"
  connection {
    user = "root"
    private_key = "${file("${var.ssh_key_path}")}"
    agent = false
  }

# 
# Call the Packet API to attach the block device to the server
#
# NB: Before calling "destroy", you *must* ssh to the server and do "bash packet-block-storage/packet-block-storage-detach".
# Otherwise, the server/volume deletion *will* fail
#
  provisioner "local-exec" {
    command = "curl -X POST -H \"Content-Type: application/json\" -H \"X-Auth-Token: ${var.packet_api_key}\" -d '{\"device_id\": \"${self.id}\"}' https://api.packet.net/storage/${element(packet_volume.px-tf-centos-volume.*.id,count.index)}/attachments"
  }

  provisioner "remote-exec" {
       inline = [
         "yum -y install git",
         "git clone https://github.com/packethost/packet-block-storage.git",
         "bash packet-block-storage/packet-block-storage-attach",
         "yum install -y yum-utils",
         "yum-config-manager --add-repo https://docs.docker.com/engine/installation/linux/repo_files/centos/docker.repo",
         "yum makecache fast",
         "yum -y install docker-engine",
         "systemctl enable docker",
         "systemctl start docker",
       ]
     }
}


#
# Run etcd on the first server
#
resource "null_resource" "run-etcd" {
  depends_on = ["packet_device.centos7"]
  connection {
    user = "root"
    private_key = "${file("${var.ssh_key_path}")}"
    host = "${packet_device.centos7.0.network.0.address}"
    agent = false
  }

  provisioner "remote-exec" {
       inline = [ "docker run -d --name etcd -v /var/lib/etcd:/var/lib/etcd --net=host --entrypoint=/usr/local/bin/etcd quay.io/coreos/etcd:latest --listen-peer-urls 'http://0.0.0.0:2380' --data-dir=/var/lib/etcd/ --listen-client-urls 'http://0.0.0.0:2379' --advertise-client-urls 'http://${packet_device.centos7.0.network.2.address}:2379'" ]
  }
}

#
# Run PX on all servers
#
resource "null_resource" "run-px" {
  depends_on = ["null_resource.run-etcd"]
  count = "${var.packet_count}"
  connection {
    user = "root"
    private_key = "${file("${var.ssh_key_path}")}"
    host = "${element(packet_device.centos7.*.network.0.address, count.index)}"
    agent = false
  }
   provisioner "remote-exec" {
     inline = [ "docker run --restart=always --name px -d --net=host --privileged=true -v /run/docker/plugins:/run/docker/plugins -v /var/lib/osd:/var/lib/osd:shared -v /dev:/dev -v /etc/pwx:/etc/pwx -v /opt/pwx/bin:/export_bin:shared -v /var/run/docker.sock:/var/run/docker.sock -v /var/cores:/var/cores -v /usr/src:/usr/src -v /lib/modules:/lib/modules --ipc=host portworx/px-dev -daemon -k etcd://${packet_device.centos7.0.network.2.address}:2379 -c MY_CLUSTER_ID -s /dev/dm-0 -d team0:0 -m team0:0" ]
   }
}

