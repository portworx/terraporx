resource "aws_launch_configuration" "default" {
  name = "${var.namespace}"

  image_id      = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"

  security_groups      = ["${aws_security_group.default.id}"]

  ebs_block_device =  {
    device_name                 = "/dev/xvdd"
    volume_type                 = "gp2"
    volume_size                 = "${var.volsize}"
    delete_on_termination       = "true"
  }

  user_data = <<EOF
#!/bin/bash
sudo ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
echo "${file("${var.pub_key}")}" >> ~/.ssh/authorized_keys
echo "${file("${var.pub_key}")}" > /root/.ssh/authorized_keys
sudo apt-get -y update
sudo apt-get -y install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get -y update
sudo apt-get -y install ansible
EOF

}

resource "aws_autoscaling_group" "default" {
  name     = "${var.namespace}"
  max_size =  "30"
  min_size = "${var.instances}"

  launch_configuration = "${aws_launch_configuration.default.name}"
  vpc_zone_identifier  = ["${aws_subnet.default.*.id}"]

  tag = {
    key                 = "Name"
    value               = "${var.namespace}"
    propagate_at_launch = true
  }

}
