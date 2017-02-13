# Portworx stacks for Terraform on Packet

## Background
Packet requires use of its [packet-block-storage](https://github.com/packethost/packet-block-storage) package.
This dynamically attaches/detaches iSCSI mounted volumes to the running image.

## Sample stacks
These sample stack illustrate spinning up Portworx on Packet for CoreOS and CentOS.
Assign variables appropriately in "vars.tf" and run "terraform apply"

## On Destroy
Before destroying, you **must** manually run the following steps:

For each Server:
* Stop Portworx
* Run "bash packet-block-storage/packet-block-attach"

Afterwards, "terraform destroy" can be successfully run.
