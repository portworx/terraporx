# Terraporx for Digital Ocean

Scripts in this directory support the Digital Ocean Cloud Provider

Instances will be created along with a corresponding non-root block volume,
to be used for the Portworx storage pool.

## Basic Portworx-ready clusters
[centos](https://github.com/portworx/terraporx/tree/master/digital_ocean/centos) brings up a 3-node px-dev cluster on CentOS 7

[coreos](https://github.com/portworx/terraporx/tree/master/digital_ocean/coreos) brings up a 3-node px-dev cluster on CoreOS

[ubuntu](https://github.com/portworx/terraporx/tree/master/digital_ocean/ubuntu16) brings up a 3-node px-dev cluster on Ubuntu 16

For CentOS and Ubuntu, docker will be installed, 'etcd' will be started as a container on one node, and 'px-dev' will be started on all 3.

For CoreOS, the implicit 'etcd2' service will be used on all 3 nodes (see "user_data") to support px-dev running as a systemd service.

## Portworx-ready DCOS/Mesosphere clusters
[dcos](https://github.com/portworx/terraporx/tree/master/digital_ocean/dcos) brings up a PX-ready DCOS/Mesosphere cluster on CoreOS

[dcos_centos](https://github.com/portworx/terraporx/tree/master/digital_ocean/dcos_centos) brings up a PX-ready DCOS/Mesosphere cluster on CentOS7

The Portworx frameworks can then be installed from [these instructions](https://docs.portworx.com/scheduler/mesosphere-dcos/install.html)

## Portworx-ready Kubernetes cluster
[kubernetes_ubuntu16](https://github.com/portworx/terraporx/tree/master/digital_ocean/kubernetes_ubuntu16) brings up a PX-ready Kubernetes 1.7 cluster on Ubuntu 16 with "weave" as the overlay network.

NOTE: In order for "weave" to work on Digital Ocean, the IPALLOC range needs to be modified from the default.

Portworx can then be installed as a [Kubernetes daemon set](https://docs.portworx.com/scheduler/kubernetes/install.html#install)

## Destroy/Teardown

To destroy all nodes, run ` terraform destroy --force` .
If that doesn't work, then run the following command to destroy
all volumes and instances.

```
terraform destroy -target=digitalocean_volume.px-vol --force
```
