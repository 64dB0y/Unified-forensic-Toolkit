#!/bin/bash
# 출력 결과를 logon.txt 파일로 저장

mkdir Logon
cd Logon
mkdir hash
cd ..

exec > logon.txt

# 로그온 사용자 정보 출력 스크립트
echo Collecting Logon user Information...

echo "---------------------------------------------"
echo "1. Recently logged in user information"
lastlog

echo "---------------------------------------------"
echo "2. Current logged-in user information"
who

echo "---------------------------------------------"
echo "3. User information currently accessing the system"
w

echo "---------------------------------------------"
echo "4. The name of the user who is currently connected to the system"
users

echo "---------------------------------------------"
echo "5. Recently logged out user information"
last -x | grep down 
echo "---------------------------------------------"

./hash.exe Logon/logon.txt > Logon/hash/hash.txt

echo Logon user Information Collecting Finished