variable "do_token" {
  description = "API Token"
  default = "e66158358ca25785555df55d825ed757e34fa504d59509df2455a77280892495"
}

variable "do_count" {
  description = "# minions"
  default = 3
}

variable "region" {
   description = "Block storage only available in fra1, nyc1, sfo2 and sgp2"
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
  default = "e2:79:41:e4:f8:82:27:68:79:3f:b3:5e:af:ae:39:1e"
}

variable "k8s_version" {
   # default = "1.7.1"
  default = "1.7.0"
}

variable "k8s_token" {
   default = "123456.0123456789abcdef"
}
 

