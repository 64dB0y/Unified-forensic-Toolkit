#!/bin/bash

mkdir Network
timestamp=$(date +"%Y-%m-%d %T")
echo "Network Directory Timtestamp : $timestamp" >> "../Forensic_Info.txt"
cd Network

mkdir hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Network Hash Directory Timtestamp : $timestamp" >> "../../Forensic_Info.txt"
cd ..

echo ipaddr >> Network/netinterface.txt		# Network Interface Configuration Information
timestamp=$(date +"%Y-%m-%d %T")
echo "ipaddr.txt Timtestamp : $timestamp" >> "../Forensic_Info.txt"
if ! ifconfig; then
	echo "Command failed"
	echo "Execute alternate command"
	ip addr >> Network/netinterface.txt
else
	ifconfig >> Network/netinterface.txt
	continue
fi

echo lsof -i -n >> Network/lsof.txt			# Every Opened Network Connection Information
timestamp=$(date +"%Y-%m-%d %T")
echo "lsof.txt Timtestamp : $timestamp" >> "../Forensic_Info.txt"
lsof -i -n >> Network/lsof.txt

echo ss -tulw >> Network/protocolconnection.txt	# Every TCP, UDP Connection Information
timestamp=$(date +"%Y-%m-%d %T")
echo "protocolconnection.txt Timtestamp : $timestamp" >> "../Forensic_Info.txt"
if ! netstat -tuln; then
	echo "Command failed"
	echo "Execute alternate command"
	ss -tulw >> Network/protocolconnection.txt
else
	netstat -tuln >> Network/protocolconnection.txt
	continue;
fi
	

echo Route Cache >> Network/Route.txt		# Routing Table Information
timestamp=$(date +"%Y-%m-%d %T")
echo "Route.txt Timtestamp : $timestamp" >> "../Forensic_Info.txt"
if ! route -n; then
	echo "Command failed"
	echo "Execute alternate command"
	ip route >> Network/Route.txt
else
	route -n >> Network/Route.txt
	continue;
fi

echo ARP Cache >> Network/ARP.txt			# ARP Cache Information
timestamp=$(date +"%Y-%m-%d %T")
echo "ARP.txt Timtestamp : $timestamp" >> "../Forensic_Info.txt"
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
timestamp=$(date +"%Y-%m-%d %T")
echo "DNS.txt Timtestamp : $timestamp" >> "../Forensic_Info.txt"
killall -USR1 systemd-resolved && journalctl -u systemd-resolved | grep -A 100000 "CACHE:" >> Network/DNS.txt
# For normal execution obtain administrator privileges

for file in Network/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> Network/hash/hash.txt
	./hash.exe "$file" >> Network/hash/hash.txt
	echo >> Network/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Network hash.txt Timtestamp : $timestamp" >> "../Forensic_Info.txt"

date >> Network/hash/hash.txt
echo    >> Network/hash/hash.txt
