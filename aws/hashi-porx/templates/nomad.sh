#!/bin/bash

cd /tmp
if ! nomad --version > /dev/null 2>&1
then
   NOMAD_VERSION=0.7.1
   echo "Fetching Nomad..."
   curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
   echo "Installing Nomad ..."
   unzip nomad.zip
   sudo install nomad /usr/bin/nomad
fi

mkdir -p /etc/nomad.d /mnt/nomad
chmod a+w /etc/nomad.d /mnt/nomad

retry_str=""
for i in ${*:2:$#}
do
   retry_str="$retry_str \"$i\" , "
done

(
cat <<-EOF
datacenter = "dc1"
data_dir   = "/mnt/nomad"

bind_addr = "$1"


addresses {
  # Defaults to the node's hostname. If the hostname resolves to a loopback
  # address you must manually configure advertise addresses.
  http = "$1"
  rpc  = "$1"
  serf = "$1" # non-default ports may be specified
}

advertise {
  # Defaults to the node's hostname. If the hostname resolves to a loopback
  # address you must manually configure advertise addresses.
  http = "${1}:4646"
  rpc  = "${1}:4647"
  serf = "${1}:4648" # non-default ports may be specified
}

client {
  enabled = true
  options {
    "driver.raw_exec.enable" = "1"
    "docker.privileged.enabled" = "true"
  }
}

server {
    enabled = true
    retry_join = [ $retry_str ] 
    bootstrap_expect = 3
}
consul {
  address = "$1"
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
}
EOF
) | tee /etc/nomad.d/config.hcl

(
cat <<-EOF
[Unit]
Description = "Nomad"

[Service]
# Stop consul will not mark node as failed but left
KillSignal=INT
ExecStart=/usr/bin/nomad agent -dev -config="/etc/nomad.d/config.hcl"
Restart=always
ExecStopPost=/bin/sleep 5
EOF
) | sudo tee /etc/systemd/system/nomad.service

systemctl daemon-reload
systemctl enable nomad
systemctl start nomad
