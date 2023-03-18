#!/bin/bash

mkdir Logon
cd Logon
mkdir hash
cd ..

echo Collecting Login user information...
echo Login user information >> Logon/who.txt
who >> Logon/who.txt
echo   >> Logon/who.txt

echo Collecting User logged in now...
echo User logged in now >> Logon/users.txt
users >> Logon/users.txt
echo   >> Logon/users.txt

echo Collecting Logged in User and What progress they ar doing...
echo Logged in User and What progress they ar doing >> Logon/w.txt
w >> Logon/w.txt
echo   >> Logon/w.txt

echo Collecting Login history...
echo Login history >> Logon/last.txt 
last >> Logon/last.txt
echo   >> Logon/last.txt

echo Collecting Last Login history...
echo Last Login history >> Logon/lastlog.txt
lastlog >> Logon/lastlog.txt
echo   >> Logon/lastlog.txt

echo user information hash >> Logon/hash/hash.txt
./hash.exe user_info.txt >> Logon/hash/hash.txt
date >> Logon/hash/hash.txt
echo    >> Logon/hash/hash.txt
