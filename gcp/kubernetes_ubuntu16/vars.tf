variable "project_name" { default = "portworx-poc" }

variable "machine_type" {  default = "n1-standard-2" }

variable "region" {  default = "us-central1" }

variable "region_zone" { default = "us-central1-f" }

variable "prefix" { default = "jeff" }

variable "minion-count" {
  description = "# minions"
  default = 3
}

variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "/Users/jeff/Downloads/Portworx-POC-LiquidWeb.json"
}

variable "volsize" {
   description = "Volume size "
   default = 20
}


variable "private_key_path" {
  description = "private key path"
  default = "~/.ssh/id_rsa"
}

variable "public_key_path" {
  description = "ssh_key"
  default = "~/.ssh/id_rsa.pub"
}

variable "k8s_version" {
   default = "1.7.3-01"
}

variable "k8s_init_version" {
   default = "1.7.3"
}

variable "k8s_token" {
   default = "123456.0123456789abcdef"
}
 
