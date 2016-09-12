#!/bin/bash


# Install dependencies
apt-get update
apt-get -y install \
  python-virtualenv \
  python-pip \
  python-dev \
  libffi-dev \
  libssl-dev \
  ntp \
  git \
  vim

cd /home/ubuntu

mkdir -p /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh

# Generate private key
cat > /home/ubuntu/.ssh/id_rsa <<\EOF
${ssh_private_key}
EOF

chmod 600 /home/ubuntu/.ssh/id_rsa

# Install Ansible
virtualenv .venv
source .venv/bin/activate
pip install -U pip
pip install -U setuptools
pip install markupsafe ansible

# Setup Ansible playbook
git clone https://github.com/rackerlabs/ansible-hadoop

cat > /home/ubuntu/ansible-hadoop/inventory/static <<\EOF
[master-nodes]
${replace(formatlist("master%s ansible_host=%s ansible_user=ubuntu\n", master_nodes_list, master_nodes), "B780FFEC-B661-4EB8-9236-A01737AD98B6", "")}
[slave-nodes]
${replace(formatlist("slave%s ansible_host=%s ansible_user=ubuntu\n", slave_nodes_list, slave_nodes), "B780FFEC-B661-4EB8-9236-A01737AD98B6", "")}
EOF

cat > /home/ubuntu/ansible-hadoop/playbooks/group_vars/master-nodes <<\EOF
cluster_interface: 'eth0'
EOF

cat > /home/ubuntu/ansible-hadoop/playbooks/group_vars/slave-nodes <<\EOF
cluster_interface: 'eth0'
datanode_disks: ['/dev/xvdf', '/dev/xvdg', '/dev/xvdh']
EOF

cat > /home/ubuntu/ansible-hadoop/playbooks/group_vars/all <<\EOF
---
cluster_name: 'hdp-cluster'
distro: 'hdp'
hdp_version: '2.4'
admin_password: '${admin_password}'
services_password: '${services_password}'
install_kafka: true
install_storm: true
# set to true to show host variables
debug: true
EOF

cat >> /home/ubuntu/.bashrc <<\EOF
export ANSIBLE_FORKS=10
export ANSIBLE_HOST_KEY_CHECKING=false
export ANSIBLE_HOSTS=/home/ubuntu/ansible-hadoop/inventory/static
EOF

sed -i \
  "s@\(8080/api/v1/hosts/{{\).*\( | lower }}\)@\1 hostvars[item]['ansible_fqdn']\2@" \
  /home/ubuntu/ansible-hadoop/playbooks/roles/ambari-server/tasks/prerequisites.yml

sed -i \
  "s@\['ansible_nodename'\] | lower@['ansible_fqdn'] | lower@" \
  /home/ubuntu/ansible-hadoop/playbooks/roles/ambari-server/templates/cluster-template-multi-nodes.j2

sed -i \
  -e 's/^arcadia: .*/arcadia: false/' \
  -e "s/^cluster_name: .*/cluster_name: 'hdp-cluster'/" \
  -e "s/^hdp_version: .*/hdp_version: '2.4'/" \
  -e "s/^admin_password: .*/admin_password: '${admin_password}'/" \
  -e "s/^services_password: .*/services_password: '${services_password}'/" \
  -e 's/^install_spark: .*/install_spark: false/' \
  -e 's/^install_falcon: .*/install_falcon: false/' \
  /home/ubuntu/ansible-hadoop/playbooks/group_vars/hortonworks

chown -R ubuntu: /home/ubuntu/
