#!/bin/bash

#프로세스 정보
echo Collecting Information of Acting Process
ps aux >> proc_info.txt
lsof -i -n >> proc_info.txt
