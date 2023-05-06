#!/bin/bash

# 모든 프로세스의 정보를 출력하여 프로세스 ID를 확인합니다.
ps -ef

# 가상 메모리 덤프를 생성할 프로세스의 ID를 입력받습니다.
read -p "Enter the process ID to create a virtual memory dump: " pid

# 입력받은 프로세스 ID로 가상 메모리 덤프를 생성합니다.
gcore -o core.pid $pid

