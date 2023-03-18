#!/bin/bash

logwatch >> sysinfo.txt

dmesg >> sysinfo.txt

journalctl >> sysinfo.txt

#By syslog find error logs
sudo service rsyslog start
grep "error" /var/log/syslog >> sysinfo.txt

echo System information hash >> hash/hash.txt
./hash.exe sysinfo.txt >> hash/hash.txt
date >> hash/hash.txt
echo    >> hash/hash.txt
