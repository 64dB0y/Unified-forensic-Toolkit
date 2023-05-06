#!/bin/bash

echo "Timestamp for Autorun files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Autorun Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Autorun
timestamp=$(date +"%Y-%m-%d %T")
echo "Autorun Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Autorun/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Autorun Hash Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

#List of autorun programs
ls -l /etc/init.d/ > ../mnt2/Autorun/autoinfo.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "autoinfo.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

#List of autorunning programs
systemctl list-unit-files --type=service --state=enabled >> ../mnt2/Autorun/autorunning.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "autorunning.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

for file in ../../mnt2/Autorun/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/Autorun/hash/hash.txt
	./hash.exe "$file" >> ../mnt2/Autorun/hash/hash.txt
	echo >> ../mnt2/Autorun/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Autorun hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

date >> ../mnt2/Autorun/hash/hash.txt
echo    >> ../mnt2/Autorun/hash/hash.txt

echo Autorun program Information Collecting finished
