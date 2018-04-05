# Portworx stacks for Terraform on Packet

## On Destroy
Before destroying, you **must** manually run the following steps:

* Stop Portworx
* Run "bash packet-block-storage/packet-block-attach"

Afterwards, "terraform destroy" can hopefully be successfully run.

## Notes


