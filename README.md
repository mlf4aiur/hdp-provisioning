README
======

This automation tools leverage HashiCorp [Terraform](https://www.terraform.io/) and Ansible playbook [ansible-hadoop](https://github.com/rackerlabs/ansible-hadoop) to build Hortonworks HDP cluster on AWS.

Usage
-----

Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables, and put customized variables into `terraform.tfvars`.

Terraform command examples:

Generate and show an execution plan:

    ../terraform.sh plan

Builds or changes infrastructure:

    ../terraform.sh apply

Destroy specific resource:

    ../terraform.sh destroy -target=aws_instance.master -target=aws_instance.slave -target=aws_instance.bastion

Create VPC and subnets
----------------------

Using terraform script `vpc` to creates a new AWS VPC and two subnets, one is public subnet, and another on is private subnet.

Create terraform variable file onto `vpc` directory to override default value.

    cd vpc

    cat > terraform.tfvars << \EOF
    aws_key_name = "main"
    ssh_public_key = <<KEY
    your_public_key
    KEY
    EOF

Create AWS VPC ans subnets.

    ../terraform.sh graph | dot -Tpng > graph.png
    ../terraform.sh validate
    ../terraform.sh refresh -resource=aws_default_network_acl.main
    ../terraform.sh plan
    ../terraform.sh apply

Create HDP cluster
------------------

    cd hdp-cluster

    cat > terraform.tfvars <<\EOF
    aws_vpc_id = "vpc-id"
    aws_public_subnet_id = "public-subnet-id"
    aws_private_subnet_id = "private-subnet-id"
    aws_key_name = "main"
    ssh_private_key = <<EOF
    your_private_key
    KEY
    EOF

    ../terraform.sh plan
    ../terraform.sh apply

Get bastion instance public ip address from terraform output `bastion_public_ip`, and login to it.

    ssh -i ~/.ssh/id_rsa bastion_public_ip

Test the instance connection:

    . /home/ubuntu/.venv/bin/activate
    ansible all -m ping
    ansible all -m shell -a "date"

Provision HDP cluster:

    cd ~/ansible-hadoop/
    bash hortonworks_static.sh

The HDP build in AWS private subnet, so access Ambari can be access by ssh port forwarding:

    ssh -CN -L 8080:ambari_private_ip:8080 ubuntu@bastion_public_ip
    # Username: admin
    # Password: admin123
    open http://localhost:8080

Related documents:

* [ansible-hadoop HDP installation guide](https://github.com/rackerlabs/ansible-hadoop/blob/master/INSTALL-HDP.md)
* [Ambari Blueprints](https://cwiki.apache.org/confluence/display/AMBARI/Blueprints)
* [Blueprint Support for HA Clusters](https://cwiki.apache.org/confluence/display/AMBARI/Blueprint+Support+for+HA+Clusters)
