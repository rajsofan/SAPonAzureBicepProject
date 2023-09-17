#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
sudo apt-get install dialog apt-utils -y
# Update the Os
sudo apt-get update
sudo apt-get -y upgrade

# Install Ansible

sudo apt-get install ansible -yqq

# Install Git

sudo apt-get install git -y
git clone https://AzDevOpsIAC@dev.azure.com/AzDevOpsIAC/azdevopsbicep/_git/SAPonAZUREARM

# Web Get the SelfhHosted agent

wget https://vstsagentpackage.azureedge.net/agent/3.225.0/vsts-agent-linux-x64-3.225.0.tar.gz

mkdir myagent
cd myagent
tar zxvf ~/vsts-agent-linux-x64-3.225.0.tar.gz

ssh-keygen -t ed25519 -C "ansible" -q -N '' -f "/home/adminuser/.ssh/ansible" <<< y

