#!/bin/bash

#로그온 정보
echo Login user information
who >> user_info.txt

echo User logged in now
users >> user_info.txt

echo Logged in User and What progress they ar doing
w >> user_info.txt

echo Login history 
last >> user_info.txt

echo Last Login history
lastlog >> user_info.txt
