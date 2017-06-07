# Azure CoreOS VM cluster

This script creates a 3 node cluster, with an additional non-root datadisk ("/dev/sdc" of size 128GB).

The default OS is CoreOS:Stable:1235.9.0

The Provider.tf file contains the secrets/credentials that can be obtained via
https://michaelheap.com/using-azure-resource-manager-with-terraform/

Follow these instructions to bring up 'etcd' and 'px-dev':
https://docs.portworx.com/scheduler/docker/install.html

After starting etcd2 as above, run the following command:

```
sudo docker run --restart=always --name px -d --net=host       \
                 --privileged=true                             \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin                   \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v /lib/modules:/lib/modules                  \
                portworx/px-dev -k etcd://$HostIP:2379 -c MY_CLUSTER_ID -s /dev/sdc             
```                
where `HostIP` corresponds to where the 'etcd' container was launched.
