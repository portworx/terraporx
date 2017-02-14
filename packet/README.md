# Portworx stacks for Terraform on Packet

## Background
Packet requires use of its [packet-block-storage](https://github.com/packethost/packet-block-storage) package.
This dynamically attaches/detaches iSCSI mounted volumes to the running image.

## Sample stacks
These sample stack illustrate spinning up Portworx on Packet for CoreOS and CentOS.
Assign variables appropriately in "vars.tf" and run "terraform apply"

##  Server Types
`Type2` is the preferred server type, which provides 1.9TB SSD per server and requires no additional block-storage.

`Type0/Type1` both require additional block-storage to work through Terraform.

## On Destroy
For **Type0/Type1** servers, before destroying, you **must** manually run the following steps:

For each Server:
* Stop Portworx
* Run "bash packet-block-storage/packet-block-attach"

Afterwards, "terraform destroy" can be successfully run.

## Notes

