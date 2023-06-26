#!/bin/bash

echo "Timestamp for System Info files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "System Info Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/System
timestamp=$(date +"%Y-%m-%d %T")
echo "System Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/System/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "System Hash Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

dmesg >> ../mnt2/System/dmesg.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "dmesg.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

journalctl >> ../mnt2/System/journalctl.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "journalctl.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

#By syslog find error logs
sudo service rsyslog start
echo Collecting Error log from /var/log/syslog...
sudo grep "error" /var/log/syslog >> ../mnt2/System/errorlog.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "errorlog.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

for file in ../../mnt2/System/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/System/hash/hash.txt
	./hash.exe "$file" >> ../mnt2/System/hash/hash.txt
	echo >> ../mnt2/System/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "System hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
date -u >> ../mnt2/System/hash.txt
echo    >> ../mnt2/System/hash.txt

echo Collecting System Information Finished
