provider "packet" {
  auth_token = "${var.packet_api_key}"
}

# Additional non-root volume needed for Portworx
resource "packet_volume" "volume1" {
    description = "px-tf-volume-1"
    facility = "${var.packet_facility}"
    project_id = "${var.packet_project_id}"
    plan = "${var.packet_storage_plan}"
    size = "${var.packet_volume_size}"
    billing_cycle = "hourly"
    snapshot_policies = { snapshot_frequency = "1day", snapshot_count = 7 }
    snapshot_policies = { snapshot_frequency = "1month", snapshot_count = 6 }
}

resource "packet_volume" "volume2" {
    description = "px-tf-volume-2"
    facility = "${var.packet_facility}"
    project_id = "${var.packet_project_id}"
    plan = "${var.packet_storage_plan}"
    size = "${var.packet_volume_size}"
    billing_cycle = "hourly"
    snapshot_policies = { snapshot_frequency = "1day", snapshot_count = 7 }
    snapshot_policies = { snapshot_frequency = "1month", snapshot_count = 6 }
}

resource "packet_volume" "volume3" {
    description = "px-tf-volume-3"
    facility = "${var.packet_facility}"
    project_id = "${var.packet_project_id}"
    plan = "${var.packet_storage_plan}"
    size = "${var.packet_volume_size}"
    billing_cycle = "hourly"
    snapshot_policies = { snapshot_frequency = "1day", snapshot_count = 7 }
    snapshot_policies = { snapshot_frequency = "1month", snapshot_count = 6 }
}


# 
# Only the first server will run 'etcd'
#
resource "packet_device" "centos7-1" {
  hostname = "${var.packet_server_hostname}-1"
  operating_system = "centos_7"
  plan          = "${var.packet_server_type}"
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
# NB: Before calling "destroy", you *must* ssh to the server and do "sh packet-block-storage/packet-block-storage-detach".
# Otherwise, the server/volume deletion *will* fail
#
  provisioner "local-exec" {
    command = "curl -X POST -H \"Content-Type: application/json\" -H \"X-Auth-Token: ${var.packet_api_key}\" -d '{\"device_id\": \"${packet_device.centos7-1.id}\"}' https://api.packet.net/storage/${packet_volume.volume1.id}/attachments"
  }


  provisioner "remote-exec" {
       inline = [
         "yum -y install git",
         "git clone https://github.com/packethost/packet-block-storage.git",
         "sh packet-block-storage/packet-block-storage-attach",
         "yum install -y yum-utils",
         "yum-config-manager --add-repo https://docs.docker.com/engine/installation/linux/repo_files/centos/docker.repo",
         "yum makecache fast",
         "yum -y install docker-engine",
         "systemctl enable docker",
         "systemctl start docker",
         "docker run -d --name etcd -v /var/lib/etcd:/var/lib/etcd --net=host --entrypoint=/usr/local/bin/etcd quay.io/coreos/etcd:latest --listen-peer-urls 'http://0.0.0.0:2380' --data-dir=/var/lib/etcd/ --listen-client-urls 'http://0.0.0.0:2379' --advertise-client-urls 'http://${packet_device.centos7-1.network.2.address}:2379'",
        "docker run --restart=always --name px -d --net=host --privileged=true -v /run/docker/plugins:/run/docker/plugins -v /var/lib/osd:/var/lib/osd:shared -v /dev:/dev -v /etc/pwx:/etc/pwx -v /opt/pwx/bin:/export_bin:shared -v /var/run/docker.sock:/var/run/docker.sock -v /var/cores:/var/cores -v /usr/src:/usr/src -v /lib/modules:/lib/modules --ipc=host portworx/px-dev -daemon -k etcd://${packet_device.centos7-1.network.2.address}:2379 -c MY_CLUSTER_ID -s /dev/dm-0 -d team0:0 -m team0:0"
       ]
     }
}


resource "packet_device" "centos7-2" {
  hostname = "${var.packet_server_hostname}-2"
  operating_system = "centos_7"
  plan          = "${var.packet_server_type}"
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
# NB: Before calling "destroy", you *must* ssh to the server and do "sh packet-block-storage/packet-block-storage-detach".
# Otherwise, the server/volume deletion *will* fail
#
  provisioner "local-exec" {
    command = "curl -X POST -H \"Content-Type: application/json\" -H \"X-Auth-Token: ${var.packet_api_key}\" -d '{\"device_id\": \"${packet_device.centos7-2.id}\"}' https://api.packet.net/storage/${packet_volume.volume2.id}/attachments"
  }


  provisioner "remote-exec" {
       inline = [
         "yum -y install git",
         "git clone https://github.com/packethost/packet-block-storage.git",
         "sh packet-block-storage/packet-block-storage-attach",
         "yum install -y yum-utils",
         "yum-config-manager --add-repo https://docs.docker.com/engine/installation/linux/repo_files/centos/docker.repo",
         "yum makecache fast",
         "yum -y install docker-engine",
         "systemctl enable docker",
         "systemctl start docker",
        "docker run --restart=always --name px -d --net=host --privileged=true -v /run/docker/plugins:/run/docker/plugins -v /var/lib/osd:/var/lib/osd:shared -v /dev:/dev -v /etc/pwx:/etc/pwx -v /opt/pwx/bin:/export_bin:shared -v /var/run/docker.sock:/var/run/docker.sock -v /var/cores:/var/cores -v /usr/src:/usr/src -v /lib/modules:/lib/modules --ipc=host portworx/px-dev -daemon -k etcd://${packet_device.centos7-1.network.2.address}:2379 -c MY_CLUSTER_ID -s /dev/dm-0 -d team0:0 -m team0:0"
       ]
     }
}

resource "packet_device" "centos7-3" {
  hostname = "${var.packet_server_hostname}-3"
  operating_system = "centos_7"
  plan          = "${var.packet_server_type}"
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
# NB: Before calling "destroy", you *must* ssh to the server and do "sh packet-block-storage/packet-block-storage-detach".
# Otherwise, the server/volume deletion *will* fail
#
  provisioner "local-exec" {
    command = "curl -X POST -H \"Content-Type: application/json\" -H \"X-Auth-Token: ${var.packet_api_key}\" -d '{\"device_id\": \"${packet_device.centos7-3.id}\"}' https://api.packet.net/storage/${packet_volume.volume3.id}/attachments"
  }


  provisioner "remote-exec" {
       inline = [
         "yum -y install git",
         "git clone https://github.com/packethost/packet-block-storage.git",
         "sh packet-block-storage/packet-block-storage-attach",
         "yum install -y yum-utils",
         "yum-config-manager --add-repo https://docs.docker.com/engine/installation/linux/repo_files/centos/docker.repo",
         "yum makecache fast",
         "yum -y install docker-engine",
         "systemctl enable docker",
         "systemctl start docker",
        "docker run --restart=always --name px -d --net=host --privileged=true -v /run/docker/plugins:/run/docker/plugins -v /var/lib/osd:/var/lib/osd:shared -v /dev:/dev -v /etc/pwx:/etc/pwx -v /opt/pwx/bin:/export_bin:shared -v /var/run/docker.sock:/var/run/docker.sock -v /var/cores:/var/cores -v /usr/src:/usr/src -v /lib/modules:/lib/modules --ipc=host portworx/px-dev -daemon -k etcd://${packet_device.centos7-1.network.2.address}:2379 -c MY_CLUSTER_ID -s /dev/dm-0 -d team0:0 -m team0:0"
       ]
     }
}
