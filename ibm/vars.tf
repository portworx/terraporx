# variable ibm_bx_api_key {}
# variable ibm_sl_api_key {}
# variable ibm_sl_username {}
variable ssh_key_path { default = "~/.ssh/id_rsa" }

variable basename { default = "jssk8s" }

variable d_eth_if { default = "eth0" }
variable m_eth_if { default = "eth0" }

variable ibm_k8s_master_count { default = 0}
variable ibm_k8s_agent_count { default = 1}
