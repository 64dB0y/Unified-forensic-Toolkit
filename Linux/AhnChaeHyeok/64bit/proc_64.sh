#!/bin/bash

mkdir Process
cd Process
mkdir hash
cd ..

echo Collecting Process Information...

echo ps aux >> Process/psaux.txt
ps aux >> Process/psaux.txt

echo lsof >> Process/lsof.txt
lsof -i -n >> Process/lsof.txt

echo psaux.txt >> Process/hash.txt
./hash.exe psaux.txt >> Process/hash.txt
echo    >> Process/hash.txt

echo lsof.txt >> Process/hash.txt
./hash.exe lsof.txt >> Process/hash.txt
date >> Process/hash.txt
echo    >> Process/hash.txt
