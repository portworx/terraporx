variable newStorageAccountName  { default = "" }

variable vmSize  { default = "Standard_A3" }

variable adminUsername  { default = "" }

variable sshKeyData  { 
          "default" = ""
          }

variable discoveryUrl  { 
    description = "Output from curl http://discovery.etcd.io/new?size=3"
}

variable sizeOfEachDataDiskInGB  { default = 128 }

