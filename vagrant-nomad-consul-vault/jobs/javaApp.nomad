job "javaJob" {
  datacenters = ["dc1"]
  type = "service"

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "webapp" {
    count = 1
    restart {
    attempts = 10
    interval = "5m"
    delay = "25s"
    mode = "delay"
  }

  task "JavaJob" {
    driver = "java"

    config {
      jar_path    = "local/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar"
      #jvm_options = ["-Xmx600m", "-Xms256m"]
      args = ["syslog"]
    }

    artifact {
      source = "https://github.com/jamalshahverdiev/vagrant-codes-in-practice/raw/master/vagrant-nomad-consul-vault/temps/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar"
      destination = "local/"
    }

    resources {
      cpu    = 100
      memory = 500

      network {
        mbits = 10
        port "http" { static = 8080 }
      }
    }

    service {
      name = "javaApp"
      port = "http"
      tags = [ "java", "app"]

      check {
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"
      }
    }
  }
  }  
}
