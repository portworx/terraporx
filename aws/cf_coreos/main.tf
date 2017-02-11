provider "aws" {
    region = "${var.region}"
}

resource "aws_cloudformation_stack" "px-stack" {
  name = "${var.stack_name}"
  template_url = "https://s3.amazonaws.com/cf-templates-1oefrvxk1p71o-us-east-1/Portworx_CoreOS_Stack_v1.2_Feb06_2017"
  parameters  {
    InstanceType = "${var.instance_type}"
    DiscoveryURL = "${var.etcd_discovery_url}"
    KeyPair = "${var.keypair}"
    VolumeSize = "${var.volsize}"
   }
}

resource "null_resource" "list-ipaddrs" {
  depends_on = ["aws_cloudformation_stack.px-stack"]
  provisioner "local-exec" {
       command = "aws --region \"${var.region}\" ec2  describe-instances --filters \"Name=tag:aws:cloudformation:stack-name,Values=\"${var.stack_name}\"\" --query 'Reservations[*].Instances[*].{IP:PublicIpAddress}' --output text"
  }
}
