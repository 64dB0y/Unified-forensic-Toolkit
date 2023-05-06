#!/bin/bash

echo "Timestamp for Log files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Log Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Log
timestamp=$(date +"%Y-%m-%d %T")
echo "Log Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Log/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Log Hash Directory Timtestamp : $timestamp" >> ../mnt2/Logon/Forensic_Info.txt

# 로그 파일이 저장되어 있는 디렉토리
log_dir="/var/log"

# 새로운 로그 파일을 저장할 디렉토리
collected_log_dir="../mnt2/Log"

# 디렉토리가 존재하지 않으면 생성
if [ ! -d "$collected_log_dir" ]; then
  mkdir "$collected_log_dir"
fi

# 로그 파일을 collected_log_dir 디렉토리로 복사
sudo cp -R "$log_dir"/*.log "$collected_log_dir"

for file in ../mnt2/Logon/*.log					# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/Log/hash/hash.txt
	./hash.exe "$file" >> ../mnt2/Log/hash/hash.txt
	echo >> ../mnt2/Log/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Log hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
date >> ../mnt2/Log/hash/hash.txt
echo    >> ../mnt2/Log/hash/hash.txt

# 복사가 완료되었음을 알림
echo "로그 파일 수집이 완료되었습니다."

