#!/bin/bash

# Get clipboard history
echo "클립보드 정보: "
xclip -o -selection clipboard > clip.txt

#작업 스케줄러 정보 출력
echo "작업스케줄러 정보: "
crontab -l > job.txt
