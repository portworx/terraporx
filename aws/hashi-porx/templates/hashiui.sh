#!/bin/bash

cd /tmp

if ! hashi-ui > /dev/null 2>&1
then
echo "Fetching hashi-ui..."
   cd /tmp
   HASHIUI_VERSION=0.23.0
   curl -sLo hashi-ui \
      https://github.com/jippi/hashi-ui/releases/download/v${HASHIUI_VERSION}/hashi-ui-linux-amd64
  sudo chmod +x hashi-ui
  sudo mv hashi-ui /usr/bin/hashi-ui
fi

echo "Installing hashi-ui..."
tee /etc/systemd/system/hashi-ui.service > /dev/null <<EOF
[Unit]
description="Hashi UI"

[Service]
KillSignal=INT
ExecStart=/usr/bin/hashi-ui --consul-enable --nomad-enable -nomad-address http://${1}:4646
Restart=always
RestartSec=5
Environment=CONSUL_ENABLE=true
Environment=NOMAD_ENABLE=true
ExecStopPost=/bin/sleep 10
EOF
systemctl daemon-reload
systemctl enable hashi-ui
systemctl start hashi-ui
