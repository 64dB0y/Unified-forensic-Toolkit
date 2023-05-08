#!/bin/bash

# Check if the OS is Ubuntu
if [ -f "/etc/lsb-release" ]; then
    # Check the architecture
    if [ "$(uname -m)" == "x86_64" ]; then
        # 64-bit Ubuntu
        bash ./Linux_Forensic_64.bash
    else
        # 32-bit Ubuntu
        bash ./Linux_Forensic_32.bash
    fi
# Check if the OS is CentOS
elif [ -f "/etc/centos-release" ]; then
    # Check the architecture
    if [ "$(uname -m)" == "x86_64" ]; then
        # 64-bit CentOS
        bash ./CentOS_Forensic_64.bash
    else
        # 32-bit CentOS
        bash ./CentOS_Forensic_32.bash
    fi
else
    echo "Unsupported OS"
fi