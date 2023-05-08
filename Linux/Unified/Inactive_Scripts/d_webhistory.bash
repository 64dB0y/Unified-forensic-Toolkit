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

# 크롬의 기록을 저장할 경로
chrome_output_path="../mnt2/Web/firefox_history.txt"

# 파이어폭스의 기록을 저장할 경로
firefox_output_path="../mnt2/Web/chrome_history.txt"

# 크롬의 기록이 저장된 데이터베이스 파일 찾기
chrome_history_file=$(find "$HOME" -name "History" | head -n 1)

if [ -z "$chrome_history_file" ]; then
    echo "Chrome history file not found."
else
    # SQL 쿼리를 사용하여 기록 추출
    sqlite3 "$chrome_history_file" "SELECT datetime(last_visit_time/1000000-11644473600, 'unixepoch'), title, url FROM urls ORDER BY last_visit_time DESC" > "$chrome_output_path"
    echo "Chrome history saved to $chrome_output_path"
    timestamp=$(date +"%Y-%m-%d %T")
    echo "Chrome history Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
fi

# 파이어폭스의 프로필 디렉토리 찾기
firefox_profile_dir=$(find "$HOME/.mozilla/firefox/" -maxdepth 1 -type d -name "*.default*" | head -n 1)

if [ -z "$firefox_profile_dir" ]; then
    # 스냅 경로에서 파이어폭스 프로필 디렉토리 찾기
    firefox_profile_dir=$(find "$HOME/snap/firefox/common/.mozilla/firefox/" -maxdepth 1 -type d -name "*.default*" | head -n 1)
fi

if [ -z "$firefox_profile_dir" ]; then
    echo "Firefox profile directory not found."
else
    # 파이어폭스의 기록이 저장된 데이터베이스 파일 찾기
    firefox_history_file="$firefox_profile_dir/places.sqlite"

    if [ ! -f "$firefox_history_file" ]; then
        echo "Firefox history file not found."
    else
        # SQL 쿼리를 사용하여 기록 추출
        sqlite3 "$firefox_history_file" "SELECT datetime(visit_date/1000000,'unixepoch'), title, url FROM moz_places, moz_historyvisits WHERE moz_places.id = moz_historyvisits.place_id ORDER BY visit_date DESC" > "$firefox_output_path"
        echo "Firefox history saved to $firefox_output_path"
        timestamp=$(date +"%Y-%m-%d %T")
        echo "Firefox history Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
    fi
fi

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