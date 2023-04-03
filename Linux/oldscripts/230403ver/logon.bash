#!/bin/bash
# 출력 결과를 logon.txt 파일로 저장

echo "Timestamp for Logon files" >> Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Logon Script Execution Timestamp : $timestamp" >> Forensic_Info.txt

mkdir Logon
timestamp=$(date +"%Y-%m-%d %T")
echo "Logon Directory Timestamp : $timestamp" >> Forensic_Info.txt
cd Logon

mkdir hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Logon Hash Directory Timtestamp : $timestamp" >> ../Forensic_Info.txt
cd ..

# Recently logged in user information
lastlog > /Logon/lastlog.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "lastlog.txt Timestamp : $timestamp" >> Forensic_Info.txt

# Current logged-in user information
who > /Logon/who.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "who.txt Timestamp : $timestamp" >> Forensic_Info.txt

# User information currently accessing the system
w > /Logon/w.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "w.txt Timestamp : $timestamp" >> Forensic_Info.txt

# The name of the user who is currently connected to the system
users > /Logon/users.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "users.txt Timestamp : $timestamp" >> Forensic_Info.txt

# Recently logged out user information
last -x | grep down > /Logon/lastdown.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "lastdown.txt Timestamp : $timestamp" >> Forensic_Info.txt

# Log in more than 5 failed logins
sudo lastb > /Logon/lastb.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "lastb.txt Timestamp : $timestamp" >> Forensic_Info.txt

for file in Logon/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> Logon/hash/hash.txt
	./hash.exe "$file" >> Logon/hash/hash.txt
	echo >> Logon/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Logon hash.txt Timtestamp : $timestamp" >> Forensic_Info.txt
date >> Logon/hash/hash.txt
echo    >> Logon/hash/hash.txt

echo Collecting Logon user Information Finished
