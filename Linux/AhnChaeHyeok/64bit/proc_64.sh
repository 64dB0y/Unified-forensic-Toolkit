#!/bin/bash

echo Collecting Information of Acting Process
ps aux >> proc_info.txt
lsof -i -n >> proc_info.txt

echo Process information hash >> hash/hash.txt
./hash.exe proc_info.txt >> hash/hash.txt
date >> hash/hash.txt
echo    >> hash/hash.txt
