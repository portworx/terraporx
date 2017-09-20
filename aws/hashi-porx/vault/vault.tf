data "template_file" "vault_startup" {
   template = "${file("${path.module}/scripts/install_vault.tpl")}"
 
    vars {
       consul_server = "${var.consul_server}"
    }
}
 

resource "aws_instance" "vault" {
    ami = "${lookup(var.ami, "${var.aws_region}-${var.platform}")}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    count = "${var.servers}"
    vpc_security_group_ids = ["${var.security_group}"]
#    security_groups = ["${var.security_group}"]
    subnet_id = "${var.subnet_id}"


    #Instance tags
    tags {
        Name = "${var.tagname}-${count.index}"
    }

    user_data = "${data.template_file.vault_startup.rendered}"
}


