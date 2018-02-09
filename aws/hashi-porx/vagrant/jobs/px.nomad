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
       interval = "4m"
       attempts = 1
       delay    = "3m"
       mode     = "delay"
    }
    task "px-task" {
       resources {
          cpu    = 500 # MHz
          memory = 1512 # MB
          network {
          port "status" {
            static = "9001"
         }
        }
       }
      driver = "raw_exec"
      config {
        command = "/bin/sh"
        args = [ "-c", "curl http://get.portworx.com | sh ; /opt/pwx/bin/px-runc run -k consul:http://127.0.0.1:8500 -c pxcluster -f -a -d enp0s8 -m enp0s8" ]
        #
        # All the Portworx command line args
        # are documented here: https://docs.portworx.com/install/docker.html#run-px
        #
     }
     service {
        port = "status"
        check {
          type     = "http"
          path     = "/status"
          interval = "10s"
          timeout  = "20s"
        }
     }
   }
 }
}
