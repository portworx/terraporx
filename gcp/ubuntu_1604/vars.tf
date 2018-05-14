
#Project Name - use the project-id for your GCP project
variable "project_name" { default = "" }

# GCP Console: IAM & Admin -> Service Accounts -> Compute Engine Default Service Account -> Create Key 
variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = ""
}

variable "machine_type" {  default = "n1-standard-2" }

variable "region" {  default = "us-central1" }

variable "region_zone" { default = "us-central1-f" }

variable "prefix" { default = "mypx" }

variable "px-count" {
  description = "# nodes"
  default = 3
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

