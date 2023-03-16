#!/bin/bash

logwatch >> sysinfo.txt       # 로그인/로그아웃 이벤트, 응용 프로그램 로그, 보안 로그, 파일 시스템 로그, 시스템 관련 이벤트 로그 정보
dmesg >> sysinfo.txt          # 부팅 메시지, 디바이스 드라이버 로그, 시스템 이벤트, 하드웨어 에러, 시스템 리소스 관련 정보
journalctl >> sysinfo.txt     # 시스템 로그, 디버깅 메시지

#By syslog find error logs
sudo service rsyslog start
grep "error" /var/log/syslog >> sysinfo.txt   # 에러 메시지를 탐색, root 계정으로 실행해야 permission denied 되지 않음

# 결과물 해시 값 저장
echo System information hash >> hash.txt
./hash/hash.exe sysinfo.txt >> hash.txt
echo    >> hash.txt
