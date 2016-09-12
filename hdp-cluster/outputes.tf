output "userdata" {
  value = "${template_file.userdata.rendered}"
}

output "bastion_public_ip" {
  value = "Bastion: ${aws_eip.bastion.public_ip}"
}

output "master_node_private_ip" {
  value = "Master Nodes: ${join(",", aws_instance.master.*.private_ip)}"
}

output "slave_node_private_ip" {
  value = "Slave Nodes: ${join(",", aws_instance.slave.*.private_ip)}"
}
