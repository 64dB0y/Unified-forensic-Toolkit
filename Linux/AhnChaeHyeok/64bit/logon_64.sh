#!/bin/bash

#로그인 유저 정보
echo Login user information
who >> user_info.txt

#현재 로그인 중인 유저
echo User logged in now
users >> user_info.txt

#현재 로그인 중인 유저와 실행중인 프로그램
echo Logged in User and What progress they ar doing
w >> user_info.txt

#로그인 기록
echo Login history 
last >> user_info.txt

#마지막 로그인 기록
echo Last Login history
lastlog >> user_info.txt

#결과물에 대한 해시 값
echo user information hash >> hash.txt
./hash/hash.exe user_info.txt >> hash.txt
date >> hash.txt
echo    >> hash.txt
