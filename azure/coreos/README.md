# Azure CoreOS VM cluster

This script creates a 3 node cluster, with an additional non-root datadisk (default size 128GB).

The default OS is CoreOS:Stable:1235.9.0

The Provider.tf file contains the secrets/credentials that can be obtained via
https://michaelheap.com/using-azure-resource-manager-with-terraform/

'etcd' does not start as intended. Therefore, run the following on all nodes as part of startup:
* 'systemctl enable etcd2'
* 'systemctl start etcd2'


