variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_region" {
  default = "ap-northeast-2"
}

variable "aws_ami" {
  description = "Ubuntu Server 14.04 LTS (HVM)"
  default     = "ami-09dc1267"
}

variable "aws_vpc_id" {
  default = "vpc-80e15be9"
}

variable "aws_public_subnet_id" {
  default = "subnet-6dbf7920"
}

variable "aws_private_subnet_id" {
  default = "subnet-6cbf7921"
}

variable "aws_key_name" {
  default     = "main"
  description = "Name of AWS key pair"
}

variable "aws_instance_type" {
  default     = "m4.large"
  description = "AWS instance type"
}

variable "ssh_private_key" {
  default = "secret"
}

variable "master_node_count" {
  default = 2
}

variable "slave_node_count" {
  default = 3
}

variable "admin_password" {
  default = "admin123"
}

variable "services_password" {
  default = "admin123"
}
