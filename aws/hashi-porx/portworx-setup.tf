module "portworx" {
    source = "./portworx"
    nomad_alb = "${aws_alb.external.dns_name}"
#     px_token = "${var.px_token}"
}
