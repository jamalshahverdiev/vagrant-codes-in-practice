job "dockerNginxApp" {
  region = "global"
  datacenters = [
    "dc1"]
  type = "service"

  group "server" {
    count = 1

    task "dockerNginxApp" {
      driver = "docker"

      constraint {
        attribute = "${attr.kernel.name}"
        value = "linux"
      }

      config {
        image = "nginx:latest"
        port_map {
          web_port = 80
        }
      }

      service {
        name = "dockerApp"
        port = "web_port"

        tags = [
          "docker",
          "app"]

        check {
          type = "http"
          path = "/"
          interval = "10s"
          timeout = "2s"
        }
      }

      resources {
        memory = 256
        network {
          mbits = 20
          port "web_port" {
	      static = "8889"
          }
        }
      }

    }
  }
}
