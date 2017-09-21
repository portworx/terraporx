job "bbox" {
  datacenters = ["dc1"]
  type = "service"

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "bbox" {
    restart {
      interval = "5m"
      attempts = 10
      delay = "25s"
      mode = "delay"
    }

    task "bbox" {
      driver = "docker"

      config {
        image = "busybox"
        network_mode = "host"
        volumes = [
            "size=10G,repl=3,name=bboxvol:/data"
         ]
         volume_driver = "pxd"
         interactive = true
      }
      resources {
        cpu = 100
        # Mhz
        memory = 64
        # MB

        }
      }
    }
}
