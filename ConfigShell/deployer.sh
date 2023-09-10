#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

# Update the Os
sudo apt-get update
sudo apt-get -y upgrade

# Install Ansible

sudo apt-get install ansible -yqq

# Install Git

sudo apt-get install git -y


# Web Get the SelfhHosted agent

wget https://vstsagentpackage.azureedge.net/agent/3.225.0/vsts-agent-linux-x64-3.225.0.tar.gz

mkdir myagent
cd myagent
tar zxvf ~/vsts-agent-linux-x64-3.225.0.tar.gz
