#!/bin/bash

mkdir Network
cd Network
mkdir hash
cd ..

echo ifconfig >> Network/ifconfig.txt
ifconfig >> Network/ifconfig.txt

echo lsof -i -n >> Network/lsof.txt
lsof -i -n >> Network/lsof.txt

echo netstat -tuln >> Network/netstat.txt
netstat -tuln >> Network/netstat.txt

echo Route Cache >> Network/Route.txt
route -n >> Network/Route.txt

echo ARP Cache >> Network/ARP.txt
cat /proc/net/arp | while read line; do
	interface=$(echo "$line" | awk '{print $6}')
	ip_address=$(echo "$line" | awk '{print $1}')
	hw_address=$(echo "$line" | awk '{print $4}')
	arp_type=$(echo "$line" | awk '{print $2}')
	
	if [ $interface != "interface" ]; then
		echo "$interface	$ip_address	$hw_address	$arp_type"
	fi
done >> Network/ARP.txt

echo DNS Cache >> Network/DNS.txt
killall -USR1 systemd-resolved && journalctl -u systemd-resolved | grep -A 100000 "CACHE:" >> Network/DNS.txt

for file in Network/*.txt
do
	./hash.exe "$file" >> Network/hash/hash.txt
	echo >> Network/hash/hash.txt
done

date >> Network/hash/hash.txt
echo    >> Network/hash/hash.txt
