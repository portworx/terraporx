# Terraporx for Digital Ocean

Scripts in this directory are targeted for the Digital Ocean Cloud Provider

Instances will be created along with a corresponding non-root block volume,
to be used for the Portworx storage pool.

These scripts will bring up a 3-node px-dev cluster in under 5 minutes.
For Ubuntu, 'etcd' will be started on one node, and 'px-dev' on all 3.
For CoreOS, the implicit 'etcd2' service will be used on all 3 nodes (see "user_data").

## Destroy/Teardown

To destroy all nodes, run the following command to destroy
all volumes and instances.

```
terraform destroy -target=digitalocean_volume.px-vol --force
```
