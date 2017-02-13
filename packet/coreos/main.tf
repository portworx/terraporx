provider "packet" {
  auth_token = "${var.packet_api_key}"
}

# Additional non-root volume needed for Portworx
resource "packet_volume" "px-tf-core-volume" {
    count = "${var.packet_count}"
    description = "px-tf-core-volume-${count.index}"
    facility = "${var.packet_facility}"
    project_id = "${var.packet_project_id}"
    plan = "${var.packet_storage_plan}"
    size = "${var.packet_volume_size}"
    billing_cycle = "hourly"
    snapshot_policies = { snapshot_frequency = "1day", snapshot_count = 7 }
    snapshot_policies = { snapshot_frequency = "1month", snapshot_count = 6 }
}

#
resource "packet_device" "coreos" {
  count = "${var.packet_count}"
  hostname = "${var.packet_server_hostname}-${count.index}"
  operating_system = "coreos_beta"
  plan          = "${var.packet_server_type}"
  facility      = "${var.packet_facility}"
  project_id    = "${var.packet_project_id}"
  billing_cycle = "hourly"
  user_data = <<EOF
#cloud-config
coreos:
   update:
        reboot-strategy: off
   etcd2:
       discovery: "${var.etcd_discovery_url}"
       advertise-client-urls: http://$private_ipv4:2379
       initial-advertise-peer-urls: http://$private_ipv4:2380
       listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
       listen-peer-urls: http://$private_ipv4:2380
   units:
       - name: etcd2.service
         command: start
       - name: portworx.service
         command: start
         content: |
            [Unit]
            Description=Portworx Container
            Wants=docker.service
            After=docker.service
            [Service]
            Restart=always
            TimeoutSec=0
            ExecStartPre=-/usr/bin/docker stop %n
            ExecStartPre=-/usr/bin/docker rm -f %n
            ExecStartPre=/usr/bin/bash -c "/usr/bin/systemctl set-environment DMPATH=`multipath -ll|grep dm-| awk '{print $2}'`"
            ExecStart=/usr/bin/docker run --net=host --privileged=true \
                   --cgroup-parent=/system.slice/portworx.service      \
                   -v /run/docker/plugins:/run/docker/plugins          \
                   -v /var/lib/osd:/var/lib/osd:shared                 \
                   -v /dev:/dev                                        \
                   -v /etc/pwx:/etc/pwx                                \
                   -v /opt/pwx/bin:/export_bin:shared                  \
                   -v /var/run/docker.sock:/var/run/docker.sock        \
                   -v /var/cores:/var/cores                            \
                   -v /lib/modules:/lib/modules                        \
                   --ipc=host                                          \
                   --name=%n                                           \
                   portworx/px-dev -s /dev/$${DMPATH} -d bond0 -m bond0 -k etcd://127.0.0.1:2379 -c px-cluster-coreos
            KillMode=control-group
            ExecStop=/usr/bin/docker stop -t 10 %n
            [Install]
            WantedBy=multi-user.target
EOF
  connection {
    user = "core"
    private_key = "${file("${var.ssh_key_path}")}"
    agent = false
  }

# 
# Call the Packet API to attach the block device to the server
#
# NB: Before calling "destroy", you *must* ssh to the server and do "sh packet-block-storage/packet-block-storage-detach".
# Otherwise, the server/volume deletion *will* fail
#
#
# Call the Packet API to attach the block device to the server
#
# NB: Before calling "destroy", you *must* ssh to the server and do "sh packet-block-storage/packet-block-storage-detach".
# Otherwise, the server/volume deletion *will* fail
#
  provisioner "local-exec" {
    command = "curl -X POST -H \"Content-Type: application/json\" -H \"X-Auth-Token: ${var.packet_api_key}\" -d '{\"device_id\": \"${self.id}\"}' https://api.packet.net/storage/${element(packet_volume.px-tf-core-volume.*.id,count.index)}/attachments"
  }
  provisioner "remote-exec" {
     inline = [
      "sudo git clone https://github.com/packethost/packet-block-storage.git",
      "sudo bash packet-block-storage/packet-block-storage-attach",
      "sudo systemctl enable docker",
      "sudo systemctl restart docker"
     ]
  }
}

