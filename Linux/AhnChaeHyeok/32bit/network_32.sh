#!/bin/bash

echo Network Information
ifconfig >> network_info.txt		# 인터페이스 명, IP/MAC 주소, 네트마스크, 브로드캐스트 주소, MTU, 인터페이스 활성화 상태, 전송/수신 속도 정보
lsof -i -n >> network_info.txt		# 현재 열려있는 네트워크 소켓에 대한 정보
netstat -tuln >> network_info.txt	# 현재 열려있는 TCP 및 UDP 포트에 대한 정보

echo Route Cache
route -n >> network_info.txt		# 라우트 캐시 정보

echo ARP Cache				# ARP 캐시 정보
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

# 결과물 해시 값 저장
echo Network information hash >> hash.txt
./hash/hash.exe network_info.txt >> hash.txt
