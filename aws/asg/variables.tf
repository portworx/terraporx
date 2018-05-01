variable "namespace" { 
  default = "jeff"
}

variable "volsize" {
   description = "Extra EBS volsize"
   default = 100
}

variable "instances" {
  description = "The number of servers."
  default = 1
}

# AWS Specific variables
variable "instance_type" {
  default = "t2.small"
}

variable "pub_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "key_name" {
  description = "The id of the ssh key to add to the servers"
  default = "jeff"
}

variable "vpc_cidr_block" {
  description = "The top-level CIDR block for the VPC."
  default     = "10.1.0.0/16"
}

variable "cidr_blocks" {
  description = "The CIDR blocks to create the workstations in."
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}
