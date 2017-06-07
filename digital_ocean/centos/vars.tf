variable "do_token" {
  description = "API Token"
  default = "e66158358ca25785555df55d825ed757e34fa504d59509df2455a77280892495"
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
  default = "./jeff.key"
}

variable "pub_key" {
  description = "ssh_key"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8l/TSsfXeyZcC1eyBvq99rgikuQcjnT+X7zjoazpsHsYoW7lNoPnrcfHLG5V7D8gfvnYktzaSmPgTLG90F1PnD6o+T38XdDhs+Hk17wQo25EVUmypmy+60DtGTggfc2cDh/0GBITcPWdFWX88Ixc9BURkE+q66hEYR+lgZ08cUTcIJqKzsjf1RnHzTeLq/S7Ws3LRgVzJr+Gab8Vjzrj2La2zjbIn4aUIxEHOmBDHkJqkz0u6bEIMr6Nz//sL1O1O5j1iBOaBIQoUt6vw3c3nCVGFZcmLsMAHgd6XVjDXPR8G3jnYRgHyPZjHrCLI3TLSxNwfV4030lPdpbOBt9ER jeff@MacBook-Pro.attlocal.net"
}

variable "ssh_fingerprint" {
  description = "fingerprint"
  default = "e2:79:41:e4:f8:82:27:68:79:3f:b3:5e:af:ae:39:1e"
}


