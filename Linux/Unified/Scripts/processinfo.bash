#!/bin/bash

mkdir Process
cd Process
mkdir hash
cd ..

# Running Process Information
echo ps aux > Process/psaux.txt
ps aux >> Process/psaux.txt

# Using top command. CPU usage information
top -b -n 1 > Process/top_info.txt

# Using pstree command
# pstree 명령어는 리눅스 시스템의 프로세스와 프로세스간의 관계를 트리구조로 보여주는 명령어
pstree -paul > Process/pstree_info.txt

# Using pgrep command
# 실행중인 프로세스의 ID를 찾는 명령어
pgrep -a bash > Process/pgrep_info.txt


# List of all network-related processes
lsof -i -n > Process/lsof.txt

# List of all open network connections
lsof -i -n | grep ESTABLISHED > Process/established.txt

# List of all UDP network connections
lsof -i -n | grep UDP > Process/udp.txt

# List of all listening TCP ports
lsof -i -n | grep LISTEN | grep TCP > Process/tcpports.txt

# List of all listening UDP ports
lsof -i -n | grep LISTEN | grep UDP > Process/udpports.txt

# Display process status information
echo "Process status information: "
echo "----------------------------------------------"
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
done > Process/status_info.txt

for file in Process/*.txt
do
    	echo "$file" >> Process/hash/hash.txt
	./hash.exe "$file" >> Process/hash/hash.txt
	echo >> Process/hash/hash.txt
done

date >> Process/hash/hash.txt
echo >> Process/hash/hash.txt
