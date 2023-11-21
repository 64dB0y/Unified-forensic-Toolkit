#!/bin/bash

echo "Timestamp for Trash files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Trash Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Trash
timestamp=$(date +"%Y-%m-%d %T")
echo "Trash Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Trash/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Trash Hash Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# 출력 파일 설정
OUTPUT_FILE="../mnt2/Trash/trash_info.txt"

grep /bin/bash /etc/passwd | cut -f1 -d: >> userlist.txt	# Save user list
file_path="./userlist.txt"
while IFS= read -r line
do
  if [ ${line} != "root" ];then	# Copy Shortcut from each user's directory
  	TRASH_DIR="/home/$line/.local/share/Trash/files"
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
	
  fi
done < "$file_path"

rm userlist.txt

for file in ../mnt2/Trash/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/Trash/hash/hash.txt
	./hash.exe "$file" >> ../mnt2/Trash/hash/hash.txt
	echo >> ../mnt2/Trash/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Trash hash.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
date >> ../mnt2/Trash/hash/hash.txt
echo    >> ../mnt2/Trash/hash/hash.txt

echo "휴지통 정보 수집을 완료했습니다. 결과는 $OUTPUT_FILE 에 저장되었습니다."

