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
done >> Network/ARP.txt

echo DNS Cache >> Network/DNS.txt
killall -USR1 systemd-resolved && journalctl -u systemd-resolved | grep -A 100000 "CACHE:" >> Network/DNS.txt

echo Network Information Collecting Finished

echo ifconfig.txt >> Network/hash/hash.txt
./hash.exe Network/ifconfig.txt >> Network/hash/hash.txt
echo    >> Network/hash/hash.txt

echo lsof.txt >> Network/hash/hash.txt
./hash.exe Network/lsof.txt >> Network/hash/hash.txt
echo    >> Network/hash/hash.txt

echo netstat.txt >> Network/hash/hash.txt
./hash.exe Network/netstat.txt >> Network/hash/hash.txt
echo    >> Network/hash/hash.txt

echo Route.txt >> Network/hash/hash.txt
./hash.exe Network/Route.txt >> Network/hash/hash.txt
echo    >> Network/hash/hash.txt

echo ARP.txt >> Network/hash/hash.txt
./hash.exe Network/ARP.txt >> Network/hash/hash.txt
echo    >> Network/hash/hash.txt

echo DNS.txt >> Network/hash/hash.txxt
./hash.exe Network/DNS.txt >> Network/hash/hash.txt
echo    >> Network/hash/hash.txt

date >> Network/hash/hash.txt
echo    >> Network/hash/hash.txt
