#!/bin/bash

mkdir Autorun
cd Autorun
mkdir hash
cd ..

echo Collecting Autorun Information...

#List of autorun programs
echo /etc/init.d/ information >> Autorun/auto.txt
ls -l /etc/init.d/ >> Autorun/auto.txt

#List of autorunning programs
echo systemctl information >> Autorun/autorunning.txt
systemctl list-unit-files --type=service --state=enabled >> Autorun/autorunning.txt

echo auto.txt >> Autorun/hash/hash.txt
./hash.exe Autorun/auto.txt >> Autorun/hash/hash.txt
echo    >> Autorun/hash/hash.txt

echo autorunning.txft >> Autorun/hash/hash.txt
./hash.exe Autorun/autorunning.txt >> Autorun/hash/hash.txt
echo    >> Autorun/hash/hash.txt

date >> Autorun/hash/hash.txt
echo    >> Autorun/hash/hash.txt

echo Autorun program Information Collecting finished
