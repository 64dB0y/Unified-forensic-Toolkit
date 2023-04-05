#!/bin/bash
# 출력 결과를 logon.txt 파일로 저장

echo "Timestamp for Logon files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Logon Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Logon
timestamp=$(date +"%Y-%m-%d %T")
echo "Logon Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Logon/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Logon Hash Directory Timtestamp : $timestamp" >> ../mnt2/Logon/Forensic_Info.txt

# Recently logged in user information
lastlog > ../mnt2/Logon/lastlog.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "lastlog.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# Current logged-in user information
who > ../mnt2/Logon/who.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "who.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# User information currently accessing the system
w > ../mnt2/Logon/w.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "w.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# The name of the user who is currently connected to the system
users > ../mnt2/Logon/users.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "users.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# Recently logged out user information
last -x | grep down > ../mnt2/Logon/lastdown.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "lastdown.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# Log in more than 5 failed logins
sudo lastb > ../mnt2/Logon/lastb.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "lastb.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

for file in ../mnt2/Logon/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/Logon/hash/hash.txt
	./hash.exe "$file" >> ../mnt2/Logon/hash/hash.txt
	echo >> ../mnt2/Logon/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Logon hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
date >> ../mnt2/Logon/hash/hash.txt
echo    >> ../mnt2/Logon/hash/hash.txt

echo Collecting Logon user Information Finished
