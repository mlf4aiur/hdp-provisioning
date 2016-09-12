output "aws_vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "main_aws_subnet_id" {
  value = "${aws_subnet.main.id}"
}

output "private_aws_subnet_id" {
  value = "${aws_subnet.private.id}"
}
