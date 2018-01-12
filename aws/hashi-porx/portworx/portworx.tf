variable "nomad_alb" { }

# Configure the Nomad provider
provider "nomad" {
  address = "http://${var.nomad_alb}:4646"
  region  = "global"
}

# resource "null_resource" "px_pause" {
#   #  Need time to settle before submitting
#   provisioner "local-exec" {
#        command = "echo 'Sleeping ...' && /bin/sleep 360"
#   } 
# }
# 
# # Run portworx
# resource "nomad_job" "pxinstaller" {
#   # Should actually depend on module.servers.aws_alb_listener.nomad (???)
#   depends_on = [ "null_resource.px_pause" ]
#   jobspec = "${file("${path.module}/portworx.nomad")}"
# }
# 
