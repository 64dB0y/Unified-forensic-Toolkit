#!/bin/bash

echo "Timestamp for Metadata files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Metadata Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Metadata
timestamp=$(date +"%Y-%m-%d %T")
echo "Metadata Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/Metadata/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Metadata Hash Directory Timtestamp : $timestamp" >> ../mnt2/Metadata/Forensic_Info.txt

# 수집할 디렉토리 경로
DIR="/"

# 수집 결과를 저장할 파일 경로
OUTPUT_FILE="../mnt2/metadata.txt"

# find 명령어를 사용하여 지정된 디렉토리 아래의 모든 파일에 대해 stat 명령어를 실행하고 결과를 파일에 저장
find "$DIR" -exec stat {} \; > "$OUTPUT_FILE"
timestamp=$(date +"%Y-%m-%d %T")
echo "metadata.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

# 수집 결과에서 필요한 정보 추출하여 새로운 파일에 저장 << 이 부분 때문에 생성 시간과 더불어 메타데이터 스크립트 실행 시간이 오래 걸리는게 아닌지?
awk '{
  if ($1 == "File:") { # 파일 정보 시작 부분인 경우
    printf "\n%s\n", $0 # 파일 정보 시작 부분 출력
  }
  else if ($1 == "Size:" || $1 == "Modify:" || $1 == "Change:") { # 파일 정보 중에서 필요한 정보인 경우
    printf "%s ", $0 # 필요한 정보 출력
  }
}' "$OUTPUT_FILE" > "formatted_metadata.txt"
timestamp=$(date +"%Y-%m-%d %T")
echo "formatted_metadata.txt Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

for file in ../mnt2/Logon/*.txt					# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/Metadata/hash/hash.txt
	./hash.exe "$file" >> ../mnt2/Metadata/hash/hash.txt
	echo >> ../mnt2/Metadata/hash/hash.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "Metadata hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
date >> ../mnt2/Metadata/hash/hash.txt
echo    >> ../mnt2/Metadata/hash/hash.txt

# 결과 출력
echo "메타데이터 수집이 완료되었습니다."
echo "수집 결과: formatted_metadata.txt"
