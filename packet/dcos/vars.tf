
variable "packet_api_key" {
  description = "Your packet API key"
  default = "pHMzxjhGexLfzFzEwCPVKS1ttCKpgb1r"
}

variable "packet_project_id" {
  description = "Packet Project ID"
  default = "13d62654-b7fc-41c2-a149-2401899cadb0"
}

variable "packet_facility" {
  description = "Packet facility: US East(ewr1), US West(sjc1), or EU(ams1). Default: sjc1"
  default = "sjc1"
}

variable "packet_agent_type" {
  description = "Instance type of Agent"
  default = "baremetal_2"
}

variable "packet_master_type" {
  description = "Instance type of Master"
  default = "baremetal_0"
}

variable "packet_boot_type" {
  description = "Instance type of bootstrap unit"
  default = "baremetal_0"
}

variable "dcos_cluster_name" {
  description = "Name of your cluster. Alpha-numeric and hyphens only, please."
  default = "packet-dcos"
} 

variable "dcos_master_count" {
  default = "1"
  description = "Number of master nodes. 1, 3, or 5."
}

variable "dcos_agent_count" {
  description = "Number of agents to deploy"
  default = "3"
}

variable "dcos_public_agent_count" {
  description = "Number of public agents to deploy"
  default = "1"
}

variable "etcd_discovery_url" {
  description = "etcd seed url: http://discovery.etcd.io/new?size=4"
  default = "https://discovery.etcd.io/b2b69000fbf032d3be07cdcf7f8840d7"
}

variable "dcos_installer_url" {
  description = "Path to get DCOS"
# default = "https://downloads.dcos.io/dcos/EarlyAccess/dcos_generate_config.sh"
  default = "https://downloads.dcos.io/dcos/stable/dcos_generate_config.sh"
} 

variable "dcos_ssh_public_key_path" {
   default = "~/.ssh/id_rsa.pub"
   description = "public key"
}
variable "dcos_ssh_key_path" {
  description = "Path to your private SSH key for the project"
  default = "~/jeff.key"
}
