variable "nomad_alb" { }

# Configure the Nomad provider
provider "nomad" {
  address = "http://${var.nomad_alb}:4646"
  region  = "global"
}

# Register a job
resource "nomad_job" "portwx" {
  jobspec = "${file("${path.module}/portworx.nomad")}"
}
