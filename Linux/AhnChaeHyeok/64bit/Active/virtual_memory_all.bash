#!/bin/bash

echo "Timestamp for Virtual Memory files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Virtual Memory Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Virtual_memory
timestamp=$(date +"%Y-%m-%d %T")
echo "Virtual Memory Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Virtual_memroy/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Virtual_memory Hash Directory Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# 가상 메모리 덤프 파일을 저장할 폴더를 생성합니다.
mkdir -p ../mnt2/Virtual_memory/core-dumps

# 현재 실행 중인 모든 프로세스의 정보를 출력하여 프로세스 ID를 확인합니다.
ps -eo pid

# 모든 실행 중인 프로세스의 가상 메모리 덤프를 생성합니다.
for pid in $(ps -eo pid)
do
  # 프로세스 이름을 확인합니다.
  process_name=$(ps -p $pid -o comm=)

  # 프로세스 이름으로 파일 이름을 생성합니다.
  filename="core.$process_name.$pid"

  # 가상 메모리 덤프를 생성합니다.
  gcore -o ../mnt2/Virtual_memory/core-dumps/$filename $pid
  timestamp=$(date +"%Y-%m-%d %T")
  echo "Virtual Memory Dump Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
done

for file in ../mnt2/Virtual_memory/core-dumps/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/Virtual_memory/hash/hash.txt
	./hash.exe "$file" >> ../mnt2/Virtual_memory/hash/hash.txt
	echo >> ../mnt2/Virtual_memroy/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Virtual Memory Dump hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
date >> ../mnt2/Virtual_memory/hash/hash.txt
echo    >> ../mnt2/Virtual_memroy/hash/hash.txt