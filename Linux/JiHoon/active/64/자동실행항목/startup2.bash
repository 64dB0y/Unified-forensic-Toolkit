#!/bin/bash

# 이전 자동 실행 프로그램 정보 파일
OLD_INFO_FILE="autostart_programs_old.txt"

# 새로운 자동 실행 프로그램 정보 파일
NEW_INFO_FILE="autostart_programs_new.txt"

# 이전 자동 실행 프로그램 정보가 있는지 확인
if [ ! -f $OLD_INFO_FILE ]; then
    echo "이전 자동 실행 프로그램 정보 파일이 없습니다. 새로운 파일을 생성합니다."
    touch $OLD_INFO_FILE
fi

# 이전 자동 실행 프로그램 정보 파일 복사
cp $OLD_INFO_FILE $NEW_INFO_FILE

# 현재 시점에서 자동 실행되는 프로그램 정보 저장
echo "init.d scripts:" >> $NEW_INFO_FILE
echo "===================================" >> $NEW_INFO_FILE
ls -lh /etc/init.d >> $NEW_INFO_FILE

echo "rc*.d scripts:" >> $NEW_INFO_FILE
echo "===================================" >> $NEW_INFO_FILE
ls -lh /etc/rc*.d >> $NEW_INFO_FILE

# 새로운 프로그램 정보와 이전 정보를 비교하여 차이를 추출
DIFF=$(diff $OLD_INFO_FILE $NEW_INFO_FILE)

# 차이가 있는 경우에만 출력
if [ "$DIFF" != "" ]; then
    echo "자동 실행 프로그램이 변경되었습니다."
    echo "$DIFF"
fi

# 새로운 정보 파일을 이전 정보 파일로 업데이트
cp $NEW_INFO_FILE $OLD_INFO_FILE

