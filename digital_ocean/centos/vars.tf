variable "do_token" {
  description = "API Token"
  default = ""
}

variable "do_count" {
  description = "# instances"
  default = 3
}

variable "region" {
   description = "Block storage only available in fra1, nyc1, sfo2 and sgp1"
   default = "sfo2"
}

variable "size" {
   description = "Instance size: [ 2gb, 4gb, 8gb, 16gb, 32gb, 48gb, 64gb ]"
   default = "4gb"
}

variable "volsize" {
   description = "Volume size : [ 100, 250, 500, 1000, 2000 ]"
   default = 100
}

variable "prefix" {
   description = "Prefix string for volumes and instances"
   default = "my"
}

variable "ssh_key_path" {
  description = "private key path"
  default = "~/.ssh/id_rsa"
}

variable "pub_key" {
  description = "ssh_key"
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_fingerprint" {
  description = "fingerprint"
  default = ""
}


