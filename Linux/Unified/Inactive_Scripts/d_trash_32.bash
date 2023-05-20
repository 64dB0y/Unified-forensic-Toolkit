#!/bin/bash

echo "Timestamp for Trash files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Trash Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Trash
timestamp=$(date +"%Y-%m-%d %T")
echo "Trash Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Trash/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Trash Hash Directory Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# 사용자 이름 입력
read -p "사용자 이름을 입력하세요: " USERNAME

# 사용자의 홈 디렉토리 찾기
USER_HOME_DIR=$(getent passwd "$USERNAME" | cut -d: -f6)

# 휴지통 디렉토리 설정
TRASH_DIR="$USER_HOME_DIR/.local/share/Trash/files"

# 출력 파일 설정
OUTPUT_FILE="../mnt2/Trash/trash_info.txt"

# 휴지통 디렉토리 확인
if [ ! -d "$TRASH_DIR" ]; then
    echo "휴지통 디렉토리를 찾을 수 없습니다."
    echo "휴지통 디렉토리: $TRASH_DIR"
    exit 1
fi

# 휴지통 디렉토리에서 파일 및 폴더 정보 추출
echo "휴지통의 정보를 수집 중입니다..."
find "$TRASH_DIR" -mindepth 1 -exec stat '{}' \; > "$OUTPUT_FILE" 2>/dev/null
timestamp=$(date +"%Y-%m-%d %T")
echo "trash_info.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

for file in ../mnt2/Trash/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/Trash/hash/hash.txt
	./hash.exe "$file" >> ../mnt2/Trash/hash/hash.txt
	echo >> ../mnt2/Trash/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Trash hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
date -u >> ../mnt2/Trash/hash/hash.txt
echo    >> ../mnt2/Trash/hash/hash.txt

echo "휴지통 정보 수집을 완료했습니다. 결과는 $OUTPUT_FILE 에 저장되었습니다."

