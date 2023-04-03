#!/bin/bash

echo "Timestamp for Autorun files" >> Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Autorun Script Execution Timestamp : $timestamp" >> Forensic_Info.txt

mkdir Autorun
timestamp=$(date +"%Y-%m-%d %T")
echo "Autorun Directory Timestamp : $timestamp" >> Forensic_Info.txt
cd Autorun

mkdir hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Autorun Hash Directory Timestamp : $timestamp" >> ../Forensic_Info.txt
cd ..

#List of autorun programs
ls -l /etc/init.d/ > Autorun/autoinfo.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "autoinfo.txt Timestamp : $timestamp" >> Forensic_Info.txt

#List of autorunning programs
systemctl list-unit-files --type=service --state=enabled >> Autorun/autorunning.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "autorunning.txt Timestamp : $timestamp" >> Forensic_Info.txt

for file in Autorun/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> Autorun/hash/hash.txt
	./hash.exe "$file" >> Autorun/hash/hash.txt
	echo >> Autorun/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Autorun hash.txt Timtestamp : $timestamp" >> Forensic_Info.txt

date >> Autorun/hash/hash.txt
echo    >> Autorun/hash/hash.txt

echo Autorun program Information Collecting finished
