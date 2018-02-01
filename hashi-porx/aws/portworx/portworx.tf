variable "nomad_alb" { }

# Configure the Nomad provider
provider "nomad" {
  address = "http://${var.nomad_alb}:4646"
  region  = "global"
}

resource "null_resource" "wait4_nomad" {
   #  Need time to settle before submitting
   provisioner "local-exec" {
        # interpreter = [ "bash", "-c" ]
        command = <<EOF
while true
do 
    if curl http://${var.nomad_alb}:4646/v1/status/leader > /dev/null 2>&1 && ! curl http://${var.nomad_alb}:4646/v1/status/leader 2>/dev/null | egrep 'No cluster leader|Bad Gateway' && curl http://${var.nomad_alb}:4646/v1/jobs
    then
       echo Nomad is Ready
       /bin/sleep 15
       break
    else
       echo Waiting for Nomad ...
       /bin/sleep 60
    fi  
done
EOF
   } 
 }

# Register a job
resource "nomad_job" "portwx" {
  jobspec = "${file("${path.module}/px.nomad")}"
}
