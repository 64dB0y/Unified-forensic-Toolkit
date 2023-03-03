#!/bin/bash

#스크립트 파일을 실행하는 쉘 스크립트

echo "Active Data Forensics Start"

sh auto.sh    #자동 실행 정보
sh logon.sh   #로그온 정보
sh network.sh #네트워크 정보
sh proc.sh    #프로세스 정보
sh sysinfo.sh #시스템 정보 

echo "Active Data Forensics Finished"
