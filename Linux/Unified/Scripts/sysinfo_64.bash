#!/bin/bash

echo "Timestamp for System Info files" >> Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "System Info Script Execution Timestamp : $timestamp" >> Forensic_Info.txt

mkdir System
timestamp=$(date +"%Y-%m-%d %T")
echo "System Directory Timestamp : $timestamp" >> Forensic_Info.txt
cd System

mkdir hash
timestamp=$(date +"%Y-%m-%d %T")
echo "System Hash Directory Timestamp : $timestamp" >> ../Forensic_Info.txt
cd ..

logwatch > System/logwatch.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "logwatch.txt Timestamp : $timestamp" >> Forensic_Info.txt

dmesg >> System/dmesg.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "dmesg.txt Timestamp : $timestamp" >> Forensic_Info.txt

journalctl >> System/journalctl.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "journalctl.txt Timestamp : $timestamp" >> Forensic_Info.txt

#By syslog find error logs
sudo service rsyslog start
echo Collecting Error log from /var/log/syslog...
grep "error" /var/log/syslog >> System/errorlog.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "errorlog.txt Timestamp : $timestamp" >> Forensic_Info.txt

for file in System/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> System/hash/hash.txt
	./hash.exe "$file" >> System/hash/hash.txt
	echo >> System/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "System hash.txt Timtestamp : $timestamp" >> Forensic_Info.txt
date >> System/hash.txt
echo    >> System/hash.txt

echo Collecting System Information Finished
