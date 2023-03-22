#!/bin/bash

mkdir Network
cd Network
mkdir hash
cd ..

echo ifconfig >> Network/ifconfig.txt		# Network Interface Configuration Information
ifconfig >> Network/ifconfig.txt

echo lsof -i -n >> Network/lsof.txt			# Every Opened Network Connection Information
lsof -i -n >> Network/lsof.txt

echo netstat -tuln >> Network/netstat.txt	# Every TCP, UDP Connection Information
netstat -tuln >> Network/netstat.txt

echo Route Cache >> Network/Route.txt		# Routing Table Information
route -n >> Network/Route.txt

echo ARP Cache >> Network/ARP.txt			# ARP Cache Information
cat /proc/net/arp | while read line; do
	interface=$(echo "$line" | awk '{print $6}')
	ip_address=$(echo "$line" | awk '{print $1}')
	hw_address=$(echo "$line" | awk '{print $4}')
	arp_type=$(echo "$line" | awk '{print $2}')
	
	if [ $interface != "interface" ]; then
		echo "$interface	$ip_address	$hw_address	$arp_type"
	fi
done >> Network/ARP.txt

echo DNS Cache >> Network/DNS.txt			# DNS Cache Information
killall -USR1 systemd-resolved && journalctl -u systemd-resolved | grep -A 100000 "CACHE:" >> Network/DNS.txt

for file in Network/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> Network/hash/hash.txt
	./hash.exe "$file" >> Network/hash/hash.txt
	echo >> Network/hash/hash.txt
done

date >> Network/hash/hash.txt
echo    >> Network/hash/hash.txt
