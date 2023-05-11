#!/bin/bash

echo "Timestamp for Temporary files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Temporary file Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/TMP
timestamp=$(date +"%Y-%m-%d %T")
echo "Temporary file Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/TMP/metadata
timestamp=$(date +"%Y-%m-%d %T")
echo "Temporary file metadata Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/TMP/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Temporary Hash Directory Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# Collect all files in the /tmp directory
echo "Collecting temporary files in /tmp directory..."
cp -R /tmp/* ../mnt2/TMP

# Collect all files in the /var/tmp directory
echo "Collecting temporary files in /var/tmp directory..."
cp -R /var/tmp/* ../mnt2/TMP

# Collect metadata for each file
echo "Collecting metadata for collected files..."
for file in ../mnt2/TMP/*
do
    echo "Collecting metadata for file: $file"
    stat $file > ../mnt2/TMP/metadata/$(basename $file).metadata.txt
done

for file in ../mnt2/TMP/*					# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/TMP/hash/hash.txt
	sudo ./hash.exe "$file" >> ../mnt2/TMP/hash/hash.txt
	echo >> ../mnt2/TMP/hash/hash.txt
done

for file in ../mnt2/TMP/metatdata/*.txt
do
	echo "$file" >> ../mnt2/TMP/hash/hash.txt
	sudo ./hash.exe "$file" >> ../mnt2/TMP/hash/hash.txt
	echo >> ../mnt2/TMP/hash/hash.txt
done

timestamp=$(date +"%Y-%m-%d %T")
echo "Temporary hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
date >> ../mnt2/TMP/hash/hash.txt
echo    >> ../mnt2/TMP/hash/hash.txt

echo "Forensic collection for temporary files completed."
