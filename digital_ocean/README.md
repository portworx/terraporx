# Terraporx for Digital Ocean

Scripts in this directory support the Digital Ocean Cloud Provider

Instances will be created along with a corresponding non-root block volume,
to be used for the Portworx storage pool.

These scripts will bring up a 3-node px-dev cluster in under 5 minutes.

The [dcos] (https://github.com/portworx/terraporx/tree/master/digital_ocean/dcos) scripts will bring up a "Portworx-ready"
DCOS cluster.  The Portworx frameworks can then be installed from [these instructions](https://docs.portworx.com/scheduler/mesosphere-dcos/install.html)

For CentOS and Ubuntu, docker will be installed, 'etcd' will be started as a container on one node, and 'px-dev' will be started on all 3.

For CoreOS, the implicit 'etcd2' service will be used on all 3 nodes (see "user_data") to support px-dev running as a systemd service.

## Destroy/Teardown

To destroy all nodes, run the following command to destroy
all volumes and instances.

```
terraform destroy -target=digitalocean_volume.px-vol --force
```
