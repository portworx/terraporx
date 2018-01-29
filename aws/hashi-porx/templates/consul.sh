#!/bin/bash 

cd /vagrant/tmp
if ! consul --version 
then
   CONSUL_VERSION=1.0.2
   echo "Fetching Consul..."
   curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip > consul.zip
   echo "Installing Consul..."
   unzip consul.zip
   sudo install consul /usr/bin/consul
fi

retry_str=""
for i in ${*:2:$#}
do
   retry_str="$retry_str -retry-join ${i} " 
done


tee /etc/systemd/system/consul.service > /dev/null <<-EOF
    [Unit]
    Description=consul agent
    Requires=network-online.target
    After=network-online.target
    
    [Service]
    Restart=on-failure
    ExecStart=/usr/bin/consul agent -dev -bind $1 $retry_str
    ExecReload=/bin/kill -HUP $MAINPID
    
    [Install]
    WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable consul.service
systemctl start consul
