# packet-terraform
Terraform scripts for packet.net

## Lookout!  
Please follow the steps here to avoid problems with dcos-adminrouter
https://jira.mesosphere.com/browse/DCOS_OSS-683
Specifically, on the Master, Change:
```
ExecStartPre = /usr/bin/curl --fail -sS -o /dev/null 127.0.0.1:8101/acs/api/v1/groups
to
ExecStartPre = /opt/mesosphere/bin/curl --fail -sS -o /dev/null 127.0.0.1:8101/acs/api/v1/groups
Then restart the service:
systemctl daemon-reload
systemctl restart dcos-adminrouter
```




#### This repo holds [Terraform](https://www.terraform.io/) scripts to create a
1, 3, or 5 master DCOS cluster on the [packet.net](https://www.packet.net/)
provider.

#### Defaut Versions
- CoreOS alpha
- DCOS 1.8

With CoreOS, the implicit `etcd` service is used by `px-dev`

Portworx `px-dev` can be installed through the DC/OS Universe

#### With this method, the network is open by default. 
Because of this, network security is a concern and should be addressed as soon as possible by the administrator.

##### To use:

Clone or download repo.

Copy `sample.terraform.tfvars` to `terraform.tfvars` and insert your variables.

Run `terraform apply`

##### Portworx specifics

To simplify, we use of "baremetal_2" instances for the agent nodes, 
so that deployment can be done without the external volume dependency.

To deploy Portworx:

* Download the DC/OS CLI
* Install 'etcd' : dcos package install --yes etcd
* Query the 'etcd' URL : dcos task | grep etcd-server | tail -n 1 | awk '{printf "etcd://%s:%s\n", $6, $8}'
* Launch Portwork through Universe.   For `cmdargs`, use `-a -k etcd://<IP>:<PORT> -c mypx1`, where `-a` uses all available disks, and `-k` refers to the 'etcd' URL

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
