
variable "packet_api_key" {
  description = "Your packet API key"
}

variable "packet_project_id" {
  description = "Packet Project ID"
}

variable "packet_count" {
   description = "Number of Servers"
   default = 3
}

variable "etcd_discovery_url" {
  description = "etcd seed url: http://discovery.etcd.io/new?size=3"
}

variable "packet_facility" {
  description = "Packet facility: US East(ewr1), US West(sjc1), or EU(ams1). Default: sjc1"
  default = "sjc1"
}

variable "packet_server_hostname" {
  description = "Server Hostname"
  default = "px-coreos"
}

variable "ssh_key_path" {
  description = "Path to your private SSH key for the project"
}
