
module "vault" {
  source = "./vault"

  instance_type = "${var.server_instance_type}"
  security_group   = "${aws_security_group.default.id}"
  key_name         = "${aws_key_pair.nomad.key_name}"
  aws_region       = "${var.aws_region}"
  consul_server    = "${aws_alb.internal.dns_name}"
  subnet_id        = "${element(aws_subnet.default.*.id,0)}"

}

