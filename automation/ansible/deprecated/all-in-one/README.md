# Ansible All-in-one (etcd3/Portworx/Lighthouse)

Quickly deploy a full Portworx stack through Ansible, including:
* 3-node `etcd3` cluster with persistent storage as a 'systemd' service
* Lighthouse and InfluxDB for Portworx cluster management and monitoring
* 3-node `portworx` cluster deployed as a 'systemd' service

## Prerequisities

### Inventory and Hosts
The Inventory file should be of the following format:

```
[nodes]
test1 IP=70.0.68.203
test2 IP=70.0.68.204
test3 IP=70.0.68.205
[lighthouse]
test1 IP=70.0.68.203
```
The hostnames and IP addresses in the inventory file should correspond to `/etc/hosts`
<br> 
There should only be one host entry for the `lighthouse` group
<br>
There should be free/clear access for 'ssh' login to all nodes without any promptps whatsoever.

## Run All-in-One
```
ansible-playbook -i inv play.yml
```

## Verify
Access Lighthouse in a browser, corresponding to the IP address for Lighthouse.
The default login credentials are "portworx@yourcompany.com" / "admin"

