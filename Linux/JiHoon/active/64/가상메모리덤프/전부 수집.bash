#!/bin/bash

# 가상 메모리 덤프 파일을 저장할 폴더를 생성합니다.
mkdir -p ~/core-dumps

# 현재 실행 중인 모든 프로세스의 정보를 출력하여 프로세스 ID를 확인합니다.
ps -eo pid

# 모든 실행 중인 프로세스의 가상 메모리 덤프를 생성합니다.
for pid in $(ps -eo pid)
do
  # 프로세스 이름을 확인합니다.
  process_name=$(ps -p $pid -o comm=)

  # 프로세스 이름으로 파일 이름을 생성합니다.
  filename="core.$process_name.$pid"

  # 가상 메모리 덤프를 생성합니다.
  gcore -o ~/core-dumps/$filename $pid
done

