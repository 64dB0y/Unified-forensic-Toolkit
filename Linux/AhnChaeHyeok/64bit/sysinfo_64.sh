#!/bin/bash

mkdir System
cd System
mkdir hash
cd ..

echo Collecting System Information ...

logwatch >> logwatch.txt

dmesg >> dmesg.txt

journalctl >> sysinfo.txt

#By syslog find error logs
sudo service rsyslog start
grep "error" /var/log/syslog >> sysinfo.txt

echo System information hash >> hash/hash.txt
./hash.exe sysinfo.txt >> hash/hash.txt
date >> hash/hash.txt
echo    >> hash/hash.txt
