provider "packet" {
  auth_token = "${var.packet_api_key}"
}

#
resource "packet_device" "coreos" {
  count = "${var.packet_count}"
  hostname = "${var.packet_server_hostname}-${count.index}"
  operating_system = "coreos_beta"
  plan          = "baremetal_2"
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
                   portworx/px-dev -s /dev/sdc -s /dev/sdd -s /dev/sde -s /dev/sdf -d bond0 -m bond0 -k etcd://127.0.0.1:2379 -c px-cluster-coreos
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


  provisioner "remote-exec" {
     inline = [
      "sudo systemctl enable docker",
      "sudo systemctl restart docker"
     ]
  }
}

