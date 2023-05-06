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

echo psaux.txt >> Process/hash/hash.txt
./hash.exe psaux.txt >> Process/hash/hash.txt
echo    >> Process/hash/hash.txt

echo lsof.txt >> Process/hash/hash.txt
./hash.exe lsof.txt >> Process/hash/hash.txt
date >> Process/hash/hash.txt
echo    >> Process/hash/hash.txt
