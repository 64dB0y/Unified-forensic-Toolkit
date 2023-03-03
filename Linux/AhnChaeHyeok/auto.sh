#!/bin/bash

#자동실행 프로그램 항목
#List of autorun programs
echo Collecting autorun programs...
ls -l /etc/init.d/ >> auto.txt

#List of autorunning programs
echo Collecting autorunning programs...
systemctl list-unit-files --type=service --state=enabled >> auto.txt

echo Collecting finished
