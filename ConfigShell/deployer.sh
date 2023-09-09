#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

# Update the Os
apt-get update
apt-get -y upgrade

# Install Ansible

apt-get install ansible -yqq

# Install Git

apt-get install git -y


# Web Get the SelfhHosted agent

wget https://vstsagentpackage.azureedge.net/agent/3.225.0/vsts-agent-linux-x64-3.225.0.tar.gz

mkdir myagent
cd myagent
tar zxvf ~/vsts-agent-linux-x64-3.225.0.tar.gz
