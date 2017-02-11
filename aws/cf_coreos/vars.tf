variable "stack_name" {
   description = "PX Stack Name"
   default = "px-tf-stack"
}

variable "etcd_discovery_url" {
   description = "Output from 'http://discovery.etcd.io/new?size=3'"
}

variable "region" {
   description = "AWS Region"
   default = "us-east-1"
}

variable "instance_type" {
   description = "EC2 Instance Type"
   default = "t2.medium"
}

variable "keypair" {
   description = "KeyPair to connect"
}

variable "volsize" {
   description = "Size (in GB) of non-root volume"
   default = "128"
}
