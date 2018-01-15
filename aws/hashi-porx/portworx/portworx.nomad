job "portworx" {
  datacenters = ["dc1"]
  type = "system"
  update {
    stagger      = "30s"
    max_parallel = 3
  }
  group "px-group" {
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

    task "px-task" {
       resources {
          cpu    = 500 # MHz
          memory = 2048 # MB
       }
      driver = "raw_exec"
      config {
        command = "/opt/pwx/bin/px-runc"
        args = [
             "run",
             "-k", "consul:http://127.0.0.1:8500",
             "-c", "pxcluster", "-f", "-a",
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
