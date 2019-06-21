job "pythonApp" {
  # Specify this job should run in the region named "global"
  region = "global"

  # Specify this job should run in datacenter dc1
  datacenters = [
    "dc1"]

  # Run this job as a "service" type. Each job type has different properties
  type = "service"

  # A group defines a series of tasks that should be co-located on the same client (host)
  group "server" {
    count = 1

    # Create an individual task (unit of work)
    task "pythonApp" {
      driver = "exec"

      # Defines that the job should run an linux machine
      constraint {
        attribute = "${attr.kernel.name}"
        value = "linux"
      }

      # Specifies what should be executed when starting the job
      config {
        command = "/bin/sh"
        args = [
          "/local/dlLibsRun.sh"]
      }

      # Defines the source of the artifact which should be downloaded
      artifact {
        source = "https://github.com/jamalshahverdiev/vagrant-codes-in-practice/raw/master/vagrant-nomad-consul-vault/temps/pyApp.tgz"
      }

      # The service block tells Nomad how to register this service with Consul for service discovery and monitoring.
      service {
        name = "pythonApp"
        port = "http"

        tags = [
          "python",
          "app"]

        check {
          type = "http"
          path = "/"
          interval = "10s"
          timeout = "2s"
        }
      }

      # Specify the maximum resources required to run the job, include CPU, memory, and bandwidth
      resources {
        cpu = 500
        memory = 256

        network {
          mbits = 5

          port "http" {
            static = 9080
          }
        }
      }
    }
  }
}
