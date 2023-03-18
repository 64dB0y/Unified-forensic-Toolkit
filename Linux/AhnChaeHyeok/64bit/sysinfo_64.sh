#!/bin/bash

mkdir System
cd System
mkdir hash
cd ..

echo Collecting System Information ...

echo logwatch >> System/logwatch.txt
logwatch >> System/logwatch.txt

echo dmesg >> System/dmesg.txt
dmesg >> System/dmesg.txt

echo journalctl >> System/journalctl.txt
journalctl >> System/journalctl.txt

#By syslog find error logs
sudo service rsyslog start
echo Error log from /var/log/syslog
grep "error" /var/log/syslog >> System/errorlog.txt

echo logwatch.txt >> System/hash.txt
./hash.exe System/logwatch.txt >> System/hash.txt
echo    >> System/hash.txt

echo dmesg.txt >> System/hash.txt
./hash.exe System/dmesg.txt >> System/hash.txt
echo    >> System/hash.txt

echo journalctl.txt >> System/hash.txt
./hash.exe System/journalctl.txt >> System/hash.txt
echo    >> System/hash.txt

echo errorlog.txt >> System/hash.txt
./hash.exe System/errorlog.txt >> System/hash.txt
echo    >> System/hash.txt

date >> System/hash.txt
echo    >> System/hash.txt

echo >> System Information Forensic Finished
