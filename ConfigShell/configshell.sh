#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
sudo apt-get install dialog apt-utils -y


./config.sh --unattended --url https://dev.azure.com/AzDevOpsIAC --auth pat --token myToken --pool default --agent myAgent --acceptTeeEula