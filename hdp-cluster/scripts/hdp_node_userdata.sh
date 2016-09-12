#!/bin/bash


apt-get update
apt-get -y install ntp

mkdir -p /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
