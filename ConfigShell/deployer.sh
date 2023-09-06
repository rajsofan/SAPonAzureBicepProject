#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
# Update the Os
sudo apt-get update
sudo apt-get -y upgrade

# Install Ansible

sudo apt install ansible -y

# Install Git

sudo apt install git -y


# Web Get the SelfhHosted agent

wget https://vstsagentpackage.azureedge.net/agent/3.225.0/vsts-agent-linux-x64-3.225.0.tar.gz

mkdir myagent
cd myagent
tar zxvf ~/vsts-agent-linux-x64-3.225.0.tar.gz
