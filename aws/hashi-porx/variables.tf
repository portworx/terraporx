variable "server_instance_type" {
  default = "t2.micro"
}

variable "client_instance_type" {
  default = "t2.medium"
}

variable "namespace" {
  description = <<EOH
The namespace to create the virtual training lab. This should describe the
training and must be unique to all current trainings. IAM users, workstations,
and resources will be scoped under this namespace.

It is best if you add this to your .tfvars file so you do not need to type
it manually with each run
EOH
  default = "jeffpx"
}

variable "vpc_cidr_block" {
  description = "The top-level CIDR block for the VPC."
  default     = "10.1.0.0/16"
}

variable "cidr_blocks" {
  description = "The CIDR blocks to create the workstations in."
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "consul_version" {
  description = "Consul version to install"
  # default = "0.9.0"
  default = "1.0.2"
}

variable "nomad_version" {
  description = "Nomad version to install"
  # default = "0.6.3"
  default = "0.7.1"
}

variable "hashiui_version" {
  description = "Hashi-ui version to install"
  # default = "0.13.6"
  default = "0.22.0"
}

variable "consul_join_tag_key" {
  description = "AWS Tag to use for consul auto-join"
  default = "nomad_consul"
}

variable "consul_join_tag_value" {
  description = "Value to search for in auto-join tag to use for consul auto-join"
  default = "default"
}

variable "nomad_servers" {
  description = "The number of nomad servers."
  default = 3
}

variable "nomad_agents" {
  description = "The number of nomad agents"
  default = 3
}

variable "public_key_path" {
  description = "The absolute path on disk to the SSH public key."
  default     = "~/.ssh/id_rsa.pub"
}

variable "key_path" {
    default = "~/.ssh/id_rsa"
}

variable "aws_region" {
   default = "us-east-2"
}

