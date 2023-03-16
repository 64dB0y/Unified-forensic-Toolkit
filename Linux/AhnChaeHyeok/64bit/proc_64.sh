#!/bin/bash

echo Collecting Information of Acting Process
ps aux >> proc_info.txt         # 현재 시스템에서 실행 중인 프로세스 정보
lsof -i -n >> proc_info.txt     # 소켓 프로세스 ID, 이름

# 결과물 해시 값 저장
echo Process information hash >> hash.txt
./hash/hash.exe proc_info.txt >> hash.txt
