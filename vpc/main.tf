resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.101.0/24"

  tags {
    Name = "Public subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id     = "${aws_vpc.main.id}"
  depends_on = ["aws_internet_gateway.gw"]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.102.0/24"

  tags {
    Name = "Private subnet"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.main.id}"
}

resource "aws_route_table" "private" {
  vpc_id     = "${aws_vpc.main.id}"
  depends_on = ["aws_nat_gateway.gw"]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags {
    Name = "Private"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_key_pair" "main" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}
