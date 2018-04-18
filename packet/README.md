# Portworx stacks for Terraform on Packet

## On Destroy
Before destroying, you **must** manually run the following steps:

* ``systemctl stop portworx``
* ``packet-block-storage-detach``

Afterwards, "terraform destroy" can hopefully be successfully run.

## Notes


