#!/bin/bash

#List of autorun programs
echo Collecting autorun programs...
ls -l /etc/init.d/ >> auto.txt

#List of autorunning programs
echo Collecting autorunning programs...
systemctl list-unit-files --type=service --state=enabled >> auto.txt

echo Autorun program Information Collecting finished

echo Autorun program Information hash >> hash.txt
./hash/hash.exe auto.txt >> hash.txt
