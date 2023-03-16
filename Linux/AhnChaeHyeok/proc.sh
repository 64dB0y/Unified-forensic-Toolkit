#!/bin/bash

echo Collecting Information of Acting Process
ps aux >> proc_info.txt
lsof -i -n >> proc_info.txt

echo Process information hash >> hash.txt
./hash/hash.exe proc_info.txt >> hash.txt
