[Unit]
Description=Portworx Container
Wants=docker.service
After=docker.service
[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker stop %n
ExecStartPre=-/usr/bin/docker rm -f %n
ExecStart=/usr/bin/docker run --net=host --privileged=true \
      --cgroup-parent=/system.slice/px-enterprise.service \
      -v /run/docker/plugins:/run/docker/plugins     \
      -v /var/lib/osd:/var/lib/osd:shared            \
      -v /dev:/dev                                   \
      -v /etc/pwx:/etc/pwx                           \
      -v /opt/pwx/bin:/export_bin:shared             \
      -v /var/run/docker.sock:/var/run/docker.sock   \
      -v /var/cores:/var/cores                       \
      -v /usr/src:/usr/src                           \
      -e API_SERVER=http://{{hostvars[groups['lighthouse'][0]]['IP']}}   \
      --name=%n \
      portworx/px-enterprise -t {{ hostvars[groups['lighthouse'][0]]['token'].stdout }} -a -f -m {{ ansible_default_ipv4.interface }} -d {{ ansible_default_ipv4.interface }}
KillMode=control-group
ExecStop=/usr/bin/docker stop -t 10 %n
[Install]
WantedBy=multi-user.target
