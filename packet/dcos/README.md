# packet-terraform
Terraform scripts for packet.net

### This repo holds [Terraform](https://www.terraform.io/) scripts to create a
1, 3, or 5 master DCOS cluster on the [packet.net](https://www.packet.net/)
provider.

#### With this method, the network is open by default. Because of this, network
security is a concern and should be addressed as soon as possible by the administrator.

##### To use:

Clone or download repo.

Copy `sample.terraform.tfvars` to `terraform.tfvars` and insert your variables.

Run `terraform apply`

##### Theory of Operation:

This script will start the infrastructure machines (bootstrap and masters),
then collect their IPs to build an installer package on the bootstrap machine
with a static master list. All masters wait for an installation script to be
generated on the localhost, then receive that script. This script, in turn,
pings the bootstrap machine whilst waiting for the web server to come online
and serve the install script itself.

When the install script is generated, the bootstrap completes and un-blocks
the cadre of agent nodes, which are  cut loose to provision metal and
eventually install software.
