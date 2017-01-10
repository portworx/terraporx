# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_autoscaling_group" "px-asg" {
  availability_zones   = ["${split(",", var.availability_zones)}"]
  name                 = "terraform-px-asg"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.px-lc.name}"

  tag {
    key                 = "Name"
    value               = "px-asg"
    propagate_at_launch = "true"
  }
}

resource "aws_launch_configuration" "px-lc" {
  name          = "terraform-px-lc"
  image_id      = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"

  # Security group
  security_groups = ["${aws_security_group.default.id}"]
  user_data       = "${file("userdata.sh")}"
  key_name        = "${var.key_name}"
  ebs_block_device {
       device_name = "/dev/xvdb"
       volume_size = "${var.aws_volume_size}"
       volume_type = "gp2"
   }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "terraform_example_sg"
  description = "Used in the terraform"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Gossip from this group
  ingress {
    from_port   = 9001
    to_port     = 9002
    protocol    = "tcp"
    self = true
  }

  # etcd from this group
  ingress {
    from_port   = 4001
    to_port     = 4001
    protocol    = "tcp"
    self = true
  }

  # etcd from this group
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    self = true
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
