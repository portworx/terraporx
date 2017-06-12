provider "packet" {
  auth_token = "${var.packet_api_key}"
}

resource "packet_device" "centos7" {
  count = "${var.packet_count}"
  hostname = "${var.packet_server_hostname}-${count.index}"
  operating_system = "centos_7"
  plan          = "baremetal_2"
  facility      = "${var.packet_facility}"
  project_id    = "${var.packet_project_id}"
  billing_cycle = "hourly"
  connection {
    user = "root"
    private_key = "${file("${var.ssh_key_path}")}"
    agent = false
  }

  provisioner "remote-exec" {
       inline = [
         "yum install -y yum-utils",
         "yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
         "yum makecache fast",
         "yum -y install docker-ce",
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
         inline = [ "docker run --net=host -d --name etcd-v3.1.3 --volume=/tmp/etcd-data:/etcd-data quay.io/coreos/etcd:v3.1.3 /usr/local/bin/etcd --name my-etcd-1 --data-dir /etcd-data --listen-client-urls http://0.0.0.0:2379 --advertise-client-urls http://${packet_device.centos7.0.network.2.address}:2379 --listen-peer-urls http://0.0.0.0:2380 --initial-advertise-peer-urls http://${packet_device.centos7.0.network.2.address}:2380 --initial-cluster my-etcd-1=http://${packet_device.centos7.0.network.2.address}:2380 --initial-cluster-token my-etcd-token --initial-cluster-state new --auto-compaction-retention 1" ]
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
     inline = [ "docker run --restart=always --name px -d --net=host --privileged=true -v /run/docker/plugins:/run/docker/plugins -v /var/lib/osd:/var/lib/osd:shared -v /dev:/dev -v /etc/pwx:/etc/pwx -v /opt/pwx/bin:/export_bin:shared -v /var/run/docker.sock:/var/run/docker.sock -v /var/cores:/var/cores -v /usr/src:/usr/src -v /lib/modules:/lib/modules --ipc=host portworx/px-dev -daemon -k etcd://${packet_device.centos7.0.network.2.address}:2379 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdd -s /dev/sde -s /dev/sdf -d bond0:0 -m bond0:0" ]
   }
}

