job "busybox" {
  datacenters = ["dc1"]
  type        = "batch"

  group "busybox" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "busybox" {
      driver = "docker"
      
      config {
        image = "busybox"
        command = "sh"
        args = ["-c", "while true; do echo 'hello'; sleep 5; done"]
        
        volumes = [
          "name=myvol,size=10,repl=3:/data",
        ]
        volume_driver = "pxd"
      }

      resources {
        cpu    = 250
        memory = 512
      }

    }
  }
}
