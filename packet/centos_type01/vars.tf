
variable "packet_api_key" {
  description = "Your packet API key"
}

variable "packet_project_id" {
  description = "Packet Project ID"
}

variable "packet_facility" {
  description = "Packet facility: US East(ewr1), US West(sjc1), or EU(ams1). Default: sjc1"
  default = "ewr1"
}

variable "packet_count" {
    description = "Number of servers/volumes"
    default = 3
}

variable "packet_server_hostname" {
  description = "Server Hostname"
  default = "px-centos-7"
}

variable "packet_storage_plan" {
  description = "Storage Plan"
  default = "storage_1"
}

variable "packet_volume_size" {
  description = "Volume Size"
  default = 100
}

variable "packet_server_type" {
  description = "Instance type of Server"
  default = "baremetal_0"
}

variable "ssh_key_path" {
  description = "Path to your private SSH key for the project"
}
