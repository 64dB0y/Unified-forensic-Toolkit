#!/bin/bash

logwatch >> sysinfo.txt

dmesg >> sysinfo.txt

journalctl >> sysinfo.txt

#By syslog find error logs
sudo service rsyslog start
grep "error" /var/log/syslog >> sysinfo.txt

echo System information hash >> hash.txt
./hash/hash.exe sysinfo.txt >> hash.txt
