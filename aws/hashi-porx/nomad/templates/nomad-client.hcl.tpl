datacenter = "dc1"
data_dir   = "/mnt/nomad"



client {
  enabled = true
  options {
    "driver.raw_exec.enable" = "1"
    "docker.privileged.enabled" = "true"
  }
}
