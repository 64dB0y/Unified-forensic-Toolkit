#!/bin/bash

# 크롬의 기록을 저장할 경로
chrome_output_path="./chrome_history.txt"

# 파이어폭스의 기록을 저장할 경로
firefox_output_path="./firefox_history.txt"

# 크롬 설치 경로를 찾아내기
chrome_path=$(which google-chrome)
if [ -z "$chrome_path" ]; then
    echo "Google Chrome is not installed."
else
    # 크롬의 기록이 저장된 데이터베이스 파일 경로
    chrome_history_file=$(find "$HOME/.config/" -name "History" | head -n 1)
    if [ -z "$chrome_history_file" ]; then
        echo "Chrome history file not found."
    else
        # SQL 쿼리를 사용하여 기록 추출
sqlite3 -separator ' | ' "$chrome_history_file" "SELECT datetime(last_visit_time/1000000-11644473600, 'unixepoch'), title, url FROM urls ORDER BY last_visit_time DESC" | sed 's/|/ | /g' > "$chrome_output_path"
echo "Chrome history saved to $chrome_output_path"

    fi
fi

# 파이어폭스 설치 경로를 찾아내기
firefox_path=$(which firefox)
if [ -z "$firefox_path" ]; then
    echo "Mozilla Firefox is not installed."
else
    # 파이어폭스의 프로필 디렉토리 경로
    firefox_profile=$(find "$HOME/snap/firefox/common/.mozilla/firefox/" -maxdepth 1 -type d -name "*.default*" | head -n 1)
    if [ -z "$firefox_profile" ]; then
        echo "Firefox profile directory not found."
    else
        # 파이어폭스의 기록이 저장된 데이터베이스 파일 경로
        firefox_history_file="$firefox_profile/places.sqlite"
        if [ ! -f "$firefox_history_file" ]; then
            echo "Firefox history file not found."
        else
            # 파이어폭스 기록 데이터베이스의 임시 복사본 생성
            firefox_history_temp=$(mktemp)
            cp "$firefox_history_file" "$firefox_history_temp"

            # SQL 쿼리를 사용하여 기록 추출
sqlite3 -separator ' | ' "$firefox_history_temp" "SELECT datetime(visit_date/1000000,'unixepoch'), title, url FROM moz_places, moz_historyvisits WHERE moz_places.id = moz_historyvisits.place_id ORDER BY visit_date DESC" | sed 's/|/ | /g' > "$firefox_output_path"
echo "Firefox history saved to $firefox_output_path"


            # 임시 복사본 삭제
            rm "$firefox_history_temp"
        fi
    fi
fi

