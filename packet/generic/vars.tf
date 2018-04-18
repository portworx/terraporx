variable "auth_token" {
  description = "Your packet API key"
  default = ""
}

variable "projectname" {
   default = ""
}

variable "hostname" {
  default = ""
}

variable "packet_device_plan" {
  default = "baremetal_0"
}

variable "facility" {
   default = "ewr1"
}

variable "packet_count" {
  default = 3
}

variable "packet_storage_plan" {
  default = "storage_1"
}

variable "packet_volume_size" {
  default = 100
}

variable "packet_os" {     
  default = "ubuntu_16_04"
}

variable "ssh_key_path" {
   default = "~/.ssh/id_rsa"
}
