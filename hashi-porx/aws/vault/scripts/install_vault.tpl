#!/usr/bin/env bash
set -e

# Install packages
sudo apt-get update -y
sudo apt-get install -y curl unzip jq

# Download Vault into some temporary directory
curl -L https://releases.hashicorp.com/vault/0.8.2/vault_0.8.2_linux_amd64.zip > /tmp/vault.zip

# Unzip it
cd /tmp
sudo unzip vault.zip
sudo mv vault /usr/local/bin
sudo chmod 0755 /usr/local/bin/vault
sudo chown root:root /usr/local/bin/vault

# Setup the configuration
IPADDR=`ifconfig eth0 | grep "inet addr" | awk '{ print substr($2,6) }'`
cat <<EOF >/tmp/vault-config
storage "consul" {
  address = "${consul_server}:8500"
  path    = "vault"
}
listener "tcp" {
  address     = "$IPADDR:8200"
  tls_disable = 1
}
EOF
sudo mv /tmp/vault-config /usr/local/etc/vault-config.json

# Setup the init script
cat <<EOF >/tmp/upstart
description "Vault server"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

script
  if [ -f "/etc/service/vault" ]; then
    . /etc/service/vault
  fi

  # Make sure to use all our CPUs, because Vault can block a scheduler thread
  export GOMAXPROCS=`nproc`

  exec /usr/local/bin/vault server \
    -config="/usr/local/etc/vault-config.json" \
    -dev \
    >>/var/log/vault.log 2>&1
end script
EOF
sudo mv /tmp/upstart /etc/init/vault.conf

# Start Vault
sudo start vault
