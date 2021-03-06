job "mysql-server" {
  datacenters = ["dc1"]
  type        = "service"

  group "mysql-server" {
    count = 1

    task "mysql-server" {
      driver = "docker"

      env = {
          "MYSQL_ROOT_PASSWORD" = "secret"
      }
      
      config {
        image = "mysql:8.0"

        port_map {
          db = 3306
        }


        volumes = [
          "name=mysql,size=10,repl=3:/var/lib/mysql"
        ]
        volume_driver = "pxd"
      }

      resources {
        cpu    = 250
        memory = 512
        network {
          port "db" {}
        }
      }

      service {
        name = "mysql-server"
        port = "db"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
