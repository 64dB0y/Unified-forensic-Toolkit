#!/bin/bash

mkdir Logon
cd Logon
mkdir hash
cd ..

echo Collecting Logon Information...

#Collecting
echo Login user information >> Logon/who.txt
who >> Logon/who.txt

echo User logged in now >> Logon/users.txt
users >> Logon/users.txt

echo Logged in User and What progress they ar doing >> Logon/w.txt
w >> Logon/w.txt

echo Login history >> Logon/last.txt 
last >> Logon/last.txt

echo Last Login history >> Logon/lastlog.txt
lastlog >> Logon/lastlog.txt

#Hash
./hash.exe Logon/who.txt >> Logon/hash/hash.txt
echo    >> Logon/hash/hash.txt

echo users.txt >> Logon/hash/hash.txt
./hash.exe Logon/users.txt >> Logon/hash/hash.txt
echo    >> Logon/hash/hash.txt

echo w.txt >> Logon/hash/hash.txt
./hash.exe Logon/w.txt >> Logon/hash/hash.txt
echo    >> Logon/hash/hash.txt

echo last.txt >> Logon/hash/hash.txt
./hash.exe Logon/last.txt >> Logon/hash/hash.txt
echo    >> Logon/hash/hash.txt

echo lastlog.txt >> Logon/hash/hash.txt
./hash.exe Logon/lastlog.txt >> Logon/hash/hash.txt
echo    >> Logon/hash/hash.txt

date >> Logon/hash/hash.txt
echo    >> Logon/hash/hash.txt
