#!/bin/bash

echo "Timestamp for Network files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Network Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Network
timestamp=$(date +"%Y-%m-%d %T")
echo "Network Directory Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Network/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Network Hash Directory Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

echo ipaddr >> ../mnt2/Network/netinterface.txt		# Network Interface Configuration Information
timestamp=$(date +"%Y-%m-%d %T")
echo "ipaddr.txt Timtestamp : $timestamp" >> "../mnt2/Forensic_Info.txt"
if ! ifconfig; then
	echo "Command failed"
	echo "Execute alternate command"
	ip addr >> ../mnt2/Network/netinterface.txt
	echo
else
	ifconfig >> ../mnt2/Network/netinterface.txt
	continue
fi

echo lsof -i -n >> ../mnt2/Network/lsof.txt			# Every Opened Network Connection Information
timestamp=$(date +"%Y-%m-%d %T")
echo "lsof.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
lsof -i -n >> ../mnt2/Network/lsof.txt

echo ss -tulw >> ../mnt2/Network/protocolconnection.txt	# Every TCP, UDP Connection Information
timestamp=$(date +"%Y-%m-%d %T")
echo "protocolconnection.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
if ! netstat -tuln; then
	echo "Command failed"
	echo "Execute alternate command"
	ss -tulw >> ../mnt2/Network/protocolconnection.txt
	echo
else
	netstat -tuln >> ../mnt2/Network/protocolconnection.txt
	continue;
fi
	

echo Route Cache >> ../mnt2/Network/Route.txt		# Routing Table Information
timestamp=$(date +"%Y-%m-%d %T")
echo "Route.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
if ! route -n; then
	echo "Command failed"
	echo "Execute alternate command"
	ip route >> ../mnt2/Network/Route.txt
	echo
else
	route -n >> ../mnt2/Network/Route.txt
	continue;
fi

echo ARP Cache >> ../mnt2/Network/ARP.txt			# ARP Cache Information
timestamp=$(date +"%Y-%m-%d %T")
echo "ARP.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
cat /proc/net/arp | while read line; do
	interface=$(echo "$line" | awk '{print $6}')
	ip_address=$(echo "$line" | awk '{print $1}')
	hw_address=$(echo "$line" | awk '{print $4}')
	arp_type=$(echo "$line" | awk '{print $2}')
	
	if [ $interface != "interface" ]; then
		echo "$interface	$ip_address	$hw_address	$arp_type"
	fi
done >> ../mnt2/Network/ARP.txt

echo DNS Cache >> ../mnt2/Network/DNS.txt			# DNS Cache Information
timestamp=$(date +"%Y-%m-%d %T")
echo "DNS.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
killall -USR1 systemd-resolved && journalctl -u systemd-resolved | grep -A 100000 "CACHE:" >> ../mnt2/Network/DNS.txt
# For normal execution obtain administrator privileges

for file in ../../mnt2/Network/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/Network/hash/hash.txt
	./hash.exe "$file" >> ../mnt2/Network/hash/hash.txt
	echo >> ../mnt2/Network/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Network hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

date -u >> ../mnt2/Network/hash/hash.txt
echo    >> ../mnt2/Network/hash/hash.txt

echo Collecting Network Info Finished
