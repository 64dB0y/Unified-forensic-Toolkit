#!/bin/bash

echo "Timestamp for System Information files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "System Information(Inactive) Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/SysInfo_Inactive
timestamp=$(date +"%Y-%m-%d %T")
echo "System Information(Inactive) Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/SysInfo_Inactive/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "System Information(Inactive) Hash Directory Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# Get system information and save to txt file
echo "*** System Information ***" > ../mnt2/SysInfo_Inactive/system_info.txt
echo "" >> ../mnt2/SysInfo_Inactive/system_info.txt

lscpu >> ../mnt2/SysInfo_Inactive/lscpu.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "lscpu(CPU Info) Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

lsblk >> ../mnt2/SysInfo_Inactive/lsblk.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "lsblk(Block Devices) Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

lshw >> ../mnt2/SysInfo_Inactive/lshw.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "lshw(Hardware Info) Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

lsusb >> ../mnt2/SysInfo_Inactive/lsusb.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "lsusb(USB Devices) copy Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

lsmod >> ../mnt2/SysInfo_Inactive/lsmod.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "lsmod(Loaded Kernel Modules) Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

df -h >> ../mnt2/SysInfo_Inactive/df_h.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "df -h(Disk Space Info) Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

free -m >> ../mnt2/SysInfo_Inactive/free_m.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "free -m(Memory Info) Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# Get login information
login_info=$(lastlog -u $(whoami) -t 1)

# Get user information
user_info=$(id)

# Get IP address and hostname
ip_address=$(hostname -I | awk '{print $1}')
hostname=$(hostname)

# Get domain
domain=$(hostname | cut -d'.' -f2-)

# Extract fields from login_info
login_type=$(echo "$login_info" | awk '{print $3}')
login_time=$(echo "$login_info" | awk '{print $5,$6,$7}')
user_sid=$(echo "$user_info" | awk -F'[=()]' '{print $2}')
user_group_sid=$(echo "$user_info" | awk -F'[=()]' '{print $4}')
ip_address=$(echo "$ip_address")
hostname=$(echo "$hostname")
domain=$(echo "$domain")

# Print headers and values
printf "사용자명\t도메인\t로그온 유형\t로그온 한 시간\t\t\t사용자의 SID\t\t사용자가 속한 SID 그룹\t사용자가 로그온한 IP주소\t장치의 호스트명\n"
printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", "$(whoami)", "$domain", "${login_type:-N/A}", "${login_time:-N/A}", "${user_sid:-N/A}", "${user_group_sid:-N/A}", "${ip_address:-N/A}", "${hostname:-N/A}"

# Save output to file
printf "사용자명\t도메인\t로그온 유형\t로그온 한 시간\t\t\t사용자의 SID\t\t사용자가 속한 SID 그룹\t사용자가 로그온한 IP주소\t장치의 호스트명\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$(whoami)" "$domain" "${login_type:-N/A}" "${login_time:-N/A}" "${user_sid:-N/A}" "${user_group_sid:-N/A}" "${ip_address:-N/A}" "${hostname:-N/A}" > ../mnt2/SysInfo_Inactive/login_info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "login_info.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

#각 명령어의 실행 결과를 변수에 저장하고, 해당 변수를 이용하여 결과를 출력합니다. 위의 예제 코드를 실행하면 CPU 정보, 블록 디바이스 정보, 하드웨어 정보, USB 디바이스 정보, 로드된 커널 모듈 정보, 디스크 사용량 정보, 메모리 사용량 정보를 모두 출력합니다.

for file in ../mnt2/SysInfo_Inactive/*.txt				# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/SysInfo_Inactive/hash/hash.txt
	./hash.exe "$file" >> ../mnt2/SysInfo_Inactive/hash/hash.txt
	echo >> ../mnt2/SysInfo_Inactive/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Inactive SysInfo hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
date >> ../mnt2/SysInfo_Inactive/hash/hash.txt
echo    >> ../mnt2/SysInfo_Inactive/hash/hash.txt
