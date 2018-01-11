variable "nomad_alb" { }

# Configure the Nomad provider
provider "nomad" {
  address = "http://${var.nomad_alb}:4646"
  region  = "global"
}

resource "null_resource" "px_pause" {
  #  Need time to settle before submitting
  provisioner "local-exec" {
       command = "/bin/sleep 120"
  } 
}

# Register a job
resource "nomad_job" "portwx" {
  depends_on = [ "null_resource.px_pause" ]
  jobspec = "${file("${path.module}/portworx.nomad")}"
}
