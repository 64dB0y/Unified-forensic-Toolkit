#!/bin/bash

mkdir Autorun
cd Autorun
mkdir hash
cd ..

#List of autorun programs
echo Collecting autorun programs...
echo /etc/init.d/ information >> Autorun/auto.txt
echo collected date >> Autorun/auto.txt
date >> Autorun/auto.txt
echo    >> Autorun/auto.txt
ls -l /etc/init.d/ >> Autorun/auto.txt

#List of autorunning programs
echo Collecting autorunning programs...
echo systemctl information >> Autorun/autorunning.txt
echo collected date >> Autorun/autorunning.txt
date >> Autorun/autorunning.txt
systemctl list-unit-files --type=service --state=enabled >> Autorun/autorunning.txt

echo Autorun program Information Collecting finished

echo Autorun program Information hash >> Autorun/hash/hash.txt
./hash.exe Autorun/auto.txt >> Autorun/hash/hash.txt
date >> Autorun/hash/hash.txt
echo    >> Autorun/hash/hash.txt

./hash.exe Autorun/autorunning.txt >> Autorun/hash/hash.txt
date >> Autorun/hash/hash.txt
echo    >> Autorun/hash/hash.txt
