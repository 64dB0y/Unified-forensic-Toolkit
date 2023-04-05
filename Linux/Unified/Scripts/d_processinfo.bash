#!/bin/bash

echo "Timestamp for Process files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Process Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Process
timestamp=$(date +"%Y-%m-%d %T")
echo "Proces Directory Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Process/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Network Hash Directory Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# Running Process Information
echo ps aux > ../mnt2/Process/psaux.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "psaux.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
ps aux >> ../mnt2/Process/psaux.txt

# Using top command. CPU usage information
top -b -n 1 > ../mnt2/Process/top_info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "top_info Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# Using pstree command
# pstree 명령어는 리눅스 시스템의 프로세스와 프로세스간의 관계를 트리구조로 보여주는 명령어
pstree -paul > ../mnt2/Process/pstree_info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "pstree_info.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# Using pgrep command
# 실행중인 프로세스의 ID를 찾는 명령어
pgrep -a bash > ../mnt2/Process/pgrep_info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "pgrep_info.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# List of all network-related processes
lsof -i -n > ../mnt2/Process/lsof.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Process/lsof.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# List of all open network connections
lsof -i -n | grep ESTABLISHED > ../mnt2/Process/established.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "established.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# List of all UDP network connections
lsof -i -n | grep UDP > ../mnt2/Process/udp.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "udp.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# List of all listening TCP ports
lsof -i -n | grep LISTEN | grep TCP > ../mnt2/Process/tcpports.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "tcpports.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# List of all listening UDP ports
lsof -i -n | grep LISTEN | grep UDP > ../mnt2/Process/udpports.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "udpports.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# Display process status information
for i in $(ls /proc/ | grep -E '^[0-9]+$'); do
    pid=$i
    process_name=$(ps -p $pid -o comm=)
    status=$(cat /proc/$pid/status | grep State | awk '{print $2}')
    memory=$(cat /proc/$pid/status | grep VmRSS | awk '{print $2}')
    echo "Process ID: $pid"
    echo "Process Name: $process_name"
    echo "Process Status: $status"
    echo "Process Memory: $memory"
    echo "----------------------------------------------"
done > ../mnt2/Process/status_info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "status_info.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

for file in ../mnt2/Process/*.txt
do
    	echo "$file" >> ../mnt2/Process/hash/hash.txt
	./hash.exe "$file" >> ../mnt2/Process/hash/hash.txt
	echo >> ../mnt2/Process/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Network hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

date >> ../mnt2/Process/hash/hash.txt
echo >> ../mnt2/Process/hash/hash.txt

echo Collecting Process Info Finished
