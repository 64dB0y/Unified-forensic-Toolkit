#!/bin/bash

echo "Timestamp for Web History files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Web History Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Web
timestamp=$(date +"%Y-%m-%d %T")
echo "LogonWeb History Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Web/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Web History Hash Directory Timtestamp : $timestamp" >> ../mnt2/Web History/Forensic_Info.txt


# 출력 파일 설정
OUTPUT_FILE_FIREFOX=" ../mnt2/Web/firefox_history.txt"
OUTPUT_FILE_CHROME=" ../mnt2/Web/chrome_history.txt"

# Firefox 프로필 디렉토리 설정
FIREFOX_PROFILE_DIR="$HOME/.mozilla/firefox/"

# Chrome 프로필 디렉토리 설정
CHROME_PROFILE_DIR="$HOME/.config/google-chrome/Default"

# Firefox 브라우저 사용 기록 추출
echo "Firefox 브라우저 사용 기록을 수집 중입니다..."
find $FIREFOX_PROFILE_DIR -name "places.sqlite" -exec sqlite3 '{}' "SELECT datetime(last_visit_date/1000000, 'unixepoch'), url FROM moz_places ORDER BY last_visit_date DESC;" \; > $OUTPUT_FILE_FIREFOX

echo "Firefox 브라우저 사용 기록 수집을 완료했습니다. 결과는 $OUTPUT_FILE_FIREFOX 에 저장되었습니다."

# Chrome 브라우저 사용 기록 추출
echo "Chrome 브라우저 사용 기록을 수집 중입니다..."
find $CHROME_PROFILE_DIR -name "History" -exec sqlite3 '{}' "SELECT datetime(last_visit_time/1000000-11644473600, 'unixepoch'), url FROM urls ORDER BY last_visit_time DESC;" \; > $OUTPUT_FILE_CHROME

for file in ../mnt2/Web/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/Web/hash/hash.txt
	./hash.exe "$file" >> ../mnt2/Web/hash/hash.txt
	echo >> ../mnt2/Web/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Web hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
date >> ../mnt2/Web/hash/hash.txt
echo    >> ../mnt2/Web/hash/hash.txt

echo "Chrome 브라우저 사용 기록 수집을 완료했습니다. 결과는 $OUTPUT_FILE_CHROME 에 저장되었습니다."

