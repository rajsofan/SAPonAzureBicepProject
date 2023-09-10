#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
sudo apt-get install dialog apt-utils -y


./config.sh --unattended --url https://dev.azure.com/AzDevOpsIAC --auth pat --token 4os3qekbpt5gzeb26lqqwyvorh5qvdzo25olxi76x2fnbntdpfhq --pool default --agent myAgent --acceptTeeEula