#!/bin/bash

# 사용자의 홈 디렉토리 찾기
USER_HOME_DIR=$(getent passwd $(logname) | cut -d: -f6)

# 휴지통 디렉토리 설정
TRASH_DIR="$USER_HOME_DIR/.local/share/Trash/files"

# 출력 파일 설정
OUTPUT_FILE="trash_info.txt"

# 휴지통 디렉토리 확인
if [ ! -d "$TRASH_DIR" ]; then
    echo "휴지통 디렉토리를 찾을 수 없습니다."
    echo "휴지통 디렉토리: $TRASH_DIR"
    exit 1
fi

# 휴지통 디렉토리에서 파일 및 폴더 정보 추출
echo "휴지통의 정보를 수집 중입니다..."
find "$TRASH_DIR" -mindepth 1 -exec stat '{}' \; > "$OUTPUT_FILE" 2>/dev/null

echo "휴지통 정보 수집을 완료했습니다. 결과는 $OUTPUT_FILE 에 저장되었습니다."

