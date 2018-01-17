variable "nomad_alb" { }

# Configure the Nomad provider
provider "nomad" {
  address = "http://${var.nomad_alb}:4646"
  region  = "global"
}

resource "null_resource" "px_pause" {
   #  Need time to settle before submitting
   provisioner "local-exec" {
        command = "echo 'Sleeping ...' && /bin/sleep 360"
   } 
 }

# Register a job
resource "nomad_job" "portwx" {
  jobspec = "${file("${path.module}/px.nomad")}"
}
