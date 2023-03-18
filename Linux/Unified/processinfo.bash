#!/bin/bash

mkdir Process
cd Process
mkdir hash
cd ..

echo Collecting Process Information...

echo ps aux >> Process/psaux.txt
ps aux >> Process/psaux.txt

# Using top command
top -b -n 1 > top_info.txt

# Using pstree command
# pstree 명령어는 리눅스 시스템의 프로세스와 프로세스간의 관계를 트리구조로 보여주는 명령어
pstree -paul > pstree_info.txt

# Using pgrep command
# 실행중인 프로세스의 ID를 찾는 명령어
pgrep -a bash > pgrep_info.txt

echo lsof >> Process/lsof.txt
lsof -i -n >> Process/lsof.txt

echo psaux.txt >> Process/hash/hash.txt
./hash.exe psaux.txt >> Process/hash/hash.txt
echo    >> Process/hash/hash.txt

echo lsof.txt >> Process/hash/hash.txt
./hash.exe lsof.txt >> Process/hash/hash.txt
date >> Process/hash/hash.txt
echo    >> Process/hash/hash.txt
