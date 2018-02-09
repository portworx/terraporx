job "busybox" {
  datacenters = ["dc1"]
  type        = "batch"

  group "busybox" {
    count = 1
    task "busybox" {
      driver = "docker"
      
      config {
        image = "busybox"
        command = "sh"
        args = ["-c", "while true; do echo 'hello'; sleep 5; done"]
        
        volumes = [
          "name=bboxvol,size=10,repl=3:/data",
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
