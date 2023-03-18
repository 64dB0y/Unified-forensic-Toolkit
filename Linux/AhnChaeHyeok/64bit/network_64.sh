#!/bin/bash

echo Network Information
ifconfig >> network_info.txt
lsof -i -n >> network_info.txt
netstat -tuln >> network_info.txt
echo Route Cache
route -n >> network_info.txt

echo ARP Cache
cat /proc/net/arp | while read line; do
	interface=$(echo "$line" | awk '{print $6}')
	ip_address=$(echo "$line" | awk '{print $1}')
	hw_address=$(echo "$line" | awk '{print $4}')
	arp_type=$(echo "$line" | awk '{print $2}')
	
	if [ $interface != "interface" ]; then
		echo "$interface	$ip_address	$hw_address	$arp_type"
	fi
done >> network_info.txt

echo Network Information Collecting Finished

echo Network information hash >> hash/hash.txt
./hash.exe network_info.txt >> hash/hash.txt
date >> hash/hash.txt
echo    >> hash/hash.txt
