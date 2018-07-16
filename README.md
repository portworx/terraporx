# Portworx Terraform Examples

This repo contains a number of reference stack examples for how to deploy Portworx under [HashiCorp Terraform](https://www.terraform.io/)

The initial repository include examples for deploying Portworx across the following Providers:

* [AWS](https://github.com/portworx/terraporx/tree/master/aws/hashi-porx)
 
   + [ASG](https://github.com/portworx/terraporx/tree/master/aws/asg) Deploy PX-ready cluster, using Auto-scaling groups
* [Azure](https://github.com/portworx/terraporx/tree/master/azure)
* [GoogleCloudPlatform](https://github.com/portworx/terraporx/tree/master/gcp)
* [Digital Ocean](https://github.com/portworx/terraporx/tree/master/digital_ocean)
* [Hashi-Porx](https://github.com/portworx/terraporx/tree/master/hashi-porx) Full Hashicorp stack aligned for Portworx, including Consul/Nomad/Vault
* [Packet.net](https://github.com/portworx/terraporx/tree/master/packet)
* [vagrant](https://github.com/portworx/terraporx/blob/master/vagrant/README.md) Deploy PX-ready VM's with Vagrant

The goal for the *Terraporx Repo* is to provide a community resource for sharing various Terraform configurations
that make it easier to deploy and manage Portworx.    If you see potential enhancements to the existing content, 
or would like to contribute your own, please feel free to submit issues or pull-requests against this repo.

For support related issues and problems related to *Terraporx*, please open a github issue for this repo.
