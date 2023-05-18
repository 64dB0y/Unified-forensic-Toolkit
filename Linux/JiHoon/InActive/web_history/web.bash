#!/bin/bash

# 크롬의 기록을 저장할 경로
chrome_output_path="./chrome_history.txt"

# 파이어폭스의 기록을 저장할 경로
firefox_output_path="./firefox_history.txt"

# 크롬의 기록이 저장된 데이터베이스 파일 찾기
chrome_history_file=$(find "$HOME" -name "History" | head -n 1)

if [ -z "$chrome_history_file" ]; then
    echo "Chrome history file not found."
else
    # SQL 쿼리를 사용하여 기록 추출
    sqlite3 "$chrome_history_file" "SELECT datetime(last_visit_time/1000000-11644473600, 'unixepoch'), title, url FROM urls ORDER BY last_visit_time DESC" > "$chrome_output_path"
    echo "Chrome history saved to $chrome_output_path"
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
    fi
fi

