#!/bin/bash

# Get login information
login_info=$(lastlog -u $(whoami) -t 1)

# Get user information
user_info=$(id)

# Get IP address and hostname
ip_address=$(hostname -I | awk '{print $1}')
hostname=$(hostname)

# Get domain
domain=$(hostname | cut -d'.' -f2-)

# Extract fields from login_info
login_type=$(echo "$login_info" | awk '{print $3}')
login_time=$(echo "$login_info" | awk '{print $5,$6,$7}')
user_sid=$(echo "$user_info" | awk -F'[=()]' '{print $2}')
user_group_sid=$(echo "$user_info" | awk -F'[=()]' '{print $4}')
ip_address=$(echo "$ip_address")
hostname=$(echo "$hostname")
domain=$(echo "$domain")

# Print headers and values
printf "사용자명\t도메인\t로그온 유형\t로그온 한 시간\t\t\t사용자의 SID\t\t사용자가 속한 SID 그룹\t사용자가 로그온한 IP주소\t장치의 호스트명\n"
printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", "$(whoami)", "$domain", "${login_type:-N/A}", "${login_time:-N/A}", "${user_sid:-N/A}", "${user_group_sid:-N/A}", "${ip_address:-N/A}", "${hostname:-N/A}"

# Save output to file
printf "사용자명\t도메인\t로그온 유형\t로그온 한 시간\t\t\t사용자의 SID\t\t사용자가 속한 SID 그룹\t사용자가 로그온한 IP주소\t장치의 호스트명\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$(whoami)" "$domain" "${login_type:-N/A}" "${login_time:-N/A}" "${user_sid:-N/A}" "${user_group_sid:-N/A}" "${ip_address:-N/A}" "${hostname:-N/A}" > login_info4.txt
