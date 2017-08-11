variable "do_token" {
  description = "API Token"
}

variable "do_count" {
  description = "# minions"
}

variable "region" {
   description = "Block storage only available in fra1, nyc1, sfo2 and sgp2"
}

variable "size" {
   description = "Instance size: [ 2gb, 4gb, 8gb, 16gb, 32gb, 48gb, 64gb ]"
}

variable "volsize" {
   description = "Volume size : [ 100, 250, 500, 1000, 2000 ]"
}

variable "prefix" {
   description = "Prefix string for volumes and instances"
}

variable "ssh_key_path" {
  description = "private key path"
}

variable "pub_key" {
  description = "ssh_key"
}

variable "ssh_fingerprint" {
  description = "fingerprint"
}

variable "k8s_version" {
   default = "1.7.3-01"
}

variable "k8s_init_version" {
   default = "1.7.3"
}

variable "k8s_token" {
   default = "8c2350.f55343444a6ffc46"
}
 
