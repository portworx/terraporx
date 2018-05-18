# variable ibm_bx_api_key {}
# variable ibm_sl_api_key {}
# variable ibm_sl_username {}
variable ssh_key_path { default = "~/.ssh/id_rsa" }

variable basename { default = "jeff" }

variable d_eth_if { default = "eth0" }
variable m_eth_if { default = "eth0" }

variable ibm_k8s_master_count { default = 1}
variable ibm_k8s_agent_count { default = 3}

variable ibm_datacenter { default = "dal13" }
variable ibm_cores { default = "4" }
variable ibm_memory { default = "8192" }

