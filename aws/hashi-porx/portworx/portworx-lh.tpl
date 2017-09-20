job "porx" {
  datacenters = ["dc1"]
  type = "system"
  update {
    stagger      = "30s"
    max_parallel = 7
  }
  group "px" {
    # The "count" parameter specifies the number of the task groups that should
    # be running under this group. This value must be non-negative and defaults
    # to 1.
    count = 1
    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }
    restart {
      attempts = 1
      interval = "4m"
      delay = "3m"
      mode = "delay"
    }

    task "portworx" {
       resources {
          cpu    = 500 # MHz
          memory = 2048 # MB
       }
       env {
          API_SERVER = "http://lighthouse-new.portworx.com/"
      }
      driver = "docker"
      config {
          logging {
             type = "json-file"
          }
      }
      config {
        image = "portworx/px-enterprise:latest"
        volumes = [
        "/run/docker/plugins:/run/docker/plugins",
        "/var/lib/osd:/var/lib/osd:shared",
        "/dev:/dev",
        "/etc/pwx:/etc/pwx",
        "/opt/pwx/bin:/export_bin",
        "/var/run/docker.sock:/var/run/docker.sock",
        "/var/cores:/var/cores",
        "/usr/src:/usr/src"
        ]
        network_mode = "host"
        privileged = true
        args = [
             "-t", "${px_token}",
             "-f", "-a", 
             "-d", "eth0", "-m", "eth0"
        ]
        #
        # All the Portworx command line args 
        # are documented here: https://docs.portworx.com/install/docker.html#run-px
        #
     }
    }

  }
}
