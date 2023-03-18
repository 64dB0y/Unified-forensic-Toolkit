#!/bin/bash

# Get system information and save to txt file
echo "*** System Information ***" > system_info.txt
echo "" >> system_info.txt
echo "--- CPU Info ---" >> system_info.txt
lscpu >> system_info.txt
echo "" >> system_info.txt
echo "--- Block Devices ---" >> system_info.txt
lsblk >> system_info.txt
echo "" >> system_info.txt
echo "--- Hardware Info ---" >> system_info.txt
lshw >> system_info.txt
echo "" >> system_info.txt
echo "--- USB Devices ---" >> system_info.txt
lsusb >> system_info.txt
echo "" >> system_info.txt
echo "--- Loaded Kernel Modules ---" >> system_info.txt
lsmod >> system_info.txt
echo "" >> system_info.txt
echo "--- Disk Space Info ---" >> system_info.txt
df -h >> system_info.txt
echo "" >> system_info.txt
echo "--- Memory Info ---" >> system_info.txt
free -m >> system_info.txt
echo "" >> system_info.txt

# Display the content of the file
cat system_info.txt

#각 명령어의 실행 결과를 변수에 저장하고, 해당 변수를 이용하여 결과를 출력합니다. 위의 예제 코드를 실행하면 CPU 정보, 블록 디바이스 정보, 하드웨어 정보, USB 디바이스 정보, 로드된 커널 모듈 정보, 디스크 사용량 정보, 메모리 사용량 정보를 모두 출력합니다.
