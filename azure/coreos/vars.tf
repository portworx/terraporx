variable newStorageAccountName  { default = "jssacct" }

variable vmSize  { default = "Standard_A3" }

variable adminUsername  { default = "jeff" }

variable sshKeyData  { 
          "default" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8l/TSsfXeyZcC1eyBvq99rgikuQcjnT+X7zjoazpsHsYoW7lNoPnrcfHLG5V7D8gfvnYktzaSmPgTLG90F1PnD6o+T38XdDhs+Hk17wQo25EVUmypmy+60DtGTggfc2cDh/0GBITcPWdFWX88Ixc9BURkE+q66hEYR+lgZ08cUTcIJqKzsjf1RnHzTeLq/S7Ws3LRgVzJr+Gab8Vjzrj2La2zjbIn4aUIxEHOmBDHkJqkz0u6bEIMr6Nz//sL1O1O5j1iBOaBIQoUt6vw3c3nCVGFZcmLsMAHgd6XVjDXPR8G3jnYRgHyPZjHrCLI3TLSxNwfV4030lPdpbOBt9ER jeff@MacBook-Pro.attlocal.net"
          }

variable discoveryUrl  { 
    description = "Output from curl http://discovery.etcd.io/new?size=3"
}

variable sizeOfEachDataDiskInGB  { default = 128 }

