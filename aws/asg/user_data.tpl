#!/bin/bash
set -xv
terraform_version="0.10.6"
aws_access_key=""
aws_secret_key=""
aws_region="us-east-2"
volsize=60
target_instances=5
key_name="jeff"
target_namespace="robobot"
###############################################

apt-get install -y unzip

# Install Terraform
cd /tmp
wget https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip
unzip terraform_${terraform_version}_linux_amd64.zip
chmod 755 terraform
mv terraform /usr/local/bin

# Go Get TerraPorx
git clone https://github.com/portworx/terraporx.git
cd terraporx/aws/asg
cat > provider.tf <<EOF
provider "aws" {
  access_key = "${aws_access_key}"
  secret_key = "${aws_secret_key}"
  region     = "${aws_region}"
}
EOF
cat > variables.tf <<EOF
variable "namespace" {
   default = "${target_namespace}"
}

variable "volsize" {
   description = "Extra EBS volsize"
   default = ${volsize}
}

variable "instances" {
  description = "The number of servers."
  default = "${target_instances}"
}

# AWS Specific variables
variable "instance_type" {
  default = "t2.medium"
}

variable "pub_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "key_name" {
  description = "The id of the ssh key to add to the servers"
  default = "${key_name}"
}

variable "vpc_cidr_block" {
  description = "The top-level CIDR block for the VPC."
  default     = "10.1.0.0/16"
}

variable "cidr_blocks" {
  description = "The CIDR blocks to create the workstations in."
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}
EOF

terraform init
terraform apply
