#!/bin/bash

echo "init.d scripts:" > autostart_programs.txt
echo "===================================" >> autostart_programs.txt
ls -lh /etc/init.d >> autostart_programs.txt

echo "rc*.d scripts:" >> autostart_programs.txt
echo "===================================" >> autostart_programs.txt
ls -lh /etc/rc*.d >> autostart_programs.txt

