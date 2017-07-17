variable "project_name" { }

variable "machine_type" { }

variable "region" { }

variable "region_zone" { }


variable "minion-count" {
  description = "# minions"
  default = 3
}

variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
}

variable "volsize" {
   description = "Volume size "
}


variable "private_key_path" {
  description = "private key path"
}

variable "public_key_path" {
  description = "ssh_key"
}

variable "k8s_version" {
   default = "1.7.0"
}

variable "k8s_token" {
   default = "123456.0123456789abcdef"
}
 

