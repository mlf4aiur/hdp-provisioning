resource "aws_security_group" "bastion" {
  name        = "bastion-ssh"
  description = "Used in the SMS ssh"
  vpc_id      = "${var.aws_vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internal" {
  name        = "vpc-internal"
  description = "Used in the internal"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "template_file" "userdata" {
  template = "${file("scripts/userdata.sh.tpl")}"

  vars {
    ssh_private_key = "${var.ssh_private_key}"

    # work-around for B780FFEC-B661-4EB8-9236-A01737AD98B6
    # https://github.com/hashicorp/terraform/issues/2708
    master_nodes_list = "${split(",", "01,02")}"

    master_nodes      = "${split(",", join(",", aws_instance.master.*.private_dns))}"
    slave_nodes_list  = "${split(",", "01,02,03")}"
    slave_nodes       = "${split(",", join(",", aws_instance.slave.*.private_dns))}"
    admin_password    = "${var.admin_password}"
    services_password = "${var.services_password}"
  }
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
}

resource "aws_instance" "bastion" {
  instance_type          = "t2.micro"
  subnet_id              = "${var.aws_public_subnet_id}"
  ami                    = "${var.aws_ami}"
  key_name               = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}", "${aws_security_group.internal.id}"]

  root_block_device = {
    volume_type = "standard"
    volume_size = 50
  }

  user_data = "${template_file.userdata.rendered}"

  # Instance tags
  tags {
    Name = "bastion"
  }
}

resource "aws_instance" "master" {
  instance_type          = "${var.aws_instance_type}"
  subnet_id              = "${var.aws_private_subnet_id}"
  ami                    = "${var.aws_ami}"
  key_name               = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.internal.id}"]
  count                  = "${var.master_node_count}"

  root_block_device = {
    volume_type = "standard"
    volume_size = 200
  }

  user_data ="${file("scripts/hdp_node_userdata.sh")}"

  # Instance tags
  tags {
    Name = "master"
  }
}

resource "aws_instance" "slave" {
  instance_type          = "${var.aws_instance_type}"
  subnet_id              = "${var.aws_private_subnet_id}"
  ami                    = "${var.aws_ami}"
  key_name               = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.internal.id}"]
  count                  = "${var.slave_node_count}"

  root_block_device = {
    volume_type = "standard"
    volume_size = 50
  }

  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_type = "standard"
    volume_size = 200
  }

  ebs_block_device {
    device_name = "/dev/xvdg"
    volume_type = "standard"
    volume_size = 200
  }

  ebs_block_device {
    device_name = "/dev/xvdh"
    volume_type = "standard"
    volume_size = 200
  }

  user_data ="${file("scripts/hdp_node_userdata.sh")}"

  # Instance tags
  tags {
    Name = "slave"
  }
}
