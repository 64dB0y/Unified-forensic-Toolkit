#!/bin/bash

# 수집할 디렉토리 경로
DIR="/"

# 수집 결과를 저장할 파일 경로
OUTPUT_FILE="metadata.txt"

# find 명령어를 사용하여 지정된 디렉토리 아래의 모든 파일에 대해 stat 명령어를 실행하고 결과를 파일에 저장
find "$DIR" -exec stat {} \; > "$OUTPUT_FILE"

# 수집 결과에서 필요한 정보 추출하여 새로운 파일에 저장
awk '{
  if ($1 == "File:") { # 파일 정보 시작 부분인 경우
    printf "\n%s\n", $0 # 파일 정보 시작 부분 출력
  }
  else if ($1 == "Size:" || $1 == "Modify:" || $1 == "Change:") { # 파일 정보 중에서 필요한 정보인 경우
    printf "%s ", $0 # 필요한 정보 출력
  }
}' "$OUTPUT_FILE" > "formatted_metadata.txt"

# 결과 출력
echo "메타데이터 수집이 완료되었습니다."
echo "수집 결과: formatted_metadata.txt"

