# Hashi-porx

## Intro

This project implements the [Portworx](http://docs.portworx.com) data fabric (persistent data for stateful containerized applications) 
fully integrated with the HashiCorp Tools stack.

Much of this was derived from the HashiCorp [nomad-auto-join](https://github.com/hashicorp/nomad-auto-join) repo.

* Consul :  as the foundation, providing discovery service and key-value database for Nomad and Portworx
* Portworx:  for the persistent data fabric for containerized apps
* Vault:  used by Portworx to provide encrypted volumes
* Nomad:  as the scheduling mechanism to launch Portworx

This project is deployed through Terraform.

## Implementation
### Consul and Nomad 
Added an EBS volume to the `aws_launch_configuration` in [nomad/instance.tf](./nomad/instance.tf), to support Portworx requirement.

```
 ebs_block_device =  {
    device_name                 = "/dev/xvdd"
    volume_type                 = "gp2"
    volume_size                 = "${var.volsize}"
    delete_on_termination       = "true"
  }
```

Changed Nomad Client config [nomad-client-hcl.tpl](./nomad/templates/nomad-client-hcl.tpl) to allow launching of Portworx:
```
client {
  enabled = true
  options {
    "driver.raw_exec.enable" = "1"
    "docker.privileged.enabled" = "true"
  }
}
```

Changed the [Nomad load balancer](./nomad/alb.tf) to listen on the external network,
so that the terraform nomad provider could be used to deploy Portworx.

```
resource "aws_alb_listener" "nomad" {
  count = "${var.nomad_type == "server" ? 1 : 0}"

#  load_balancer_arn = "${var.internal_alb_arn}"
  load_balancer_arn = "${var.external_alb_arn}"
  [...] 
```

### Portworx 

Deploys Portworx as a `system` service through Nomad with the [portworx.nomad](./portworx/portworx.nomad) job file.

## Launch

### Prerequisites
Ensure that the following environment variables are set:

```
$ export AWS_REGION = "[AWS_REGION]"
$ export AWS_ACCESS_KEY = "[AWS_ACCESS_KEY]"
$ export AWS_SECRET_ACCESS_KEY = "[AWS_SECRET_ACCESS_KEY]"
```

### Launch Stack

```
git clone https://github.com/portworx/terraporx
cd aws/hashi-porx
terraform get
terraform plan
terraform apply
```


## Verify

### Consul

Verify Consul is up
```
ssh ubuntu@<IPaddr> consul members
```

Verify Portworx is using Consul
```
ssh ubuntu@<IPaddr> consul kv export pwx | jq .
```

Verify Vault is using Consul
```
ssh ubuntu@<IPaddr> consul kv export vault | jq .
```
### Nomad

```
http://nomad-consul-external-012345.us-east-2.elb.amazonaws.com:3000
```


### Vault

```
ssh ubuntu@<IPaddr> "VAULT_ADDR='http://127.0.0.1:8200' vault status"
```

### Portworx

Verify Portworx is operational.

Logon to a nomad client:

```
ssh ubuntu@<IPaddr> sudo /opt/pwx/bin/pxctl status
```

## Consume

### Connect Portworx to Vault

On the vault server, note Root Token via `grep Root /var/log/vault.log`
Use the values to create a secret key:

```
root@ip-10-1-1-197:/etc# export VAULT_TOKEN=d5981a2f-c617-0b87-1bcc-94bba8d6b317
root@ip-10-1-1-197:/etc# export VAULT_ADDR='http://127.0.0.1:8200'
root@ip-10-1-1-197:/etc# vault write secret/hello value=world
Success! Data written to: secret/hello
```
On nomad/portworx client, use the above `Root Token` as the `VAULT_TOKEN` below
as Portworx does login to the Vault server:

```
root@ip-10-1-1-34:~# /opt/pwx/bin/pxctl secrets vault login
Enter VAULT_ADDR: http://10.1.1.197:8200
Enter VAULT_TOKEN: ************************************
Successfully authenticated with Vault.
** WARNING, this is probably not what you want to do. This login will not be persisted across PX or node reboots. Please put your login information in /etc/pwx/config.json or refer docs.portworx.com for more information
```

Set the Cluster-wide Encryption Key for Portworx:

```
root@ip-10-1-1-34:~# /opt/pwx/bin/pxctl secrets set-cluster-key
Enter cluster wide secret key: *****         ("hello")
Successfully set cluster secret key!
```


## Caveats

* Terraform Nomad provider tries to bring up Portworx before Nomad is ready.  (Rerun "apply")

## ToDo / Next
* Cross AZ availability
* ASG's for Vault
* HA for Vault   
* Cleanup hardcoded stuff

