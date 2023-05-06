#!/bin/bash

mkdir Network
cd Network
mkdir hash
cd ..

echo Collecting Network Information...

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
done >> ARP.txt

echo Network Information Collecting Finished

echo ifconfig.txt >> Network/hash.txt
./hash.exe Network/ifconfig.txt >> Network/hash.txt
echo    >> Network/hash.txt

echo lsof.txt >> Network/hash.txt
./hash.exe Network/lsof.txt >> Network/hash.txt
echo    >> Network/hash.txt

echo netstat.txt >> Network/hash.txt
./hash.exe Network/netstat.txt >> Network/hash.txt
echo    >> Network/hash.txt

echo Route.txt >> Network/hash.txt
./hash.exe Network/Route.txt >> Network/hash.txt
echo    >> Network/hash.txt

echo ARP.txt >> Network/hash.txt
./hash.exe Network/ARP.txt >> Network/hash.txt
echo    >> Network/hash.txt

date >> Network/hash.txt
echo    >> Network/hash.txt
