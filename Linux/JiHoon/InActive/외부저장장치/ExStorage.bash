#!/bin/bash

RAW_LOG_FILE="usb_raw_logs.txt"
FORMATTED_LOG_FILE="usb_formatted_logs.txt"
SEARCH_DATE=$(date +'%Y-%m-%d')

# Search for USB connection logs before SEARCH_DATE
journalctl -o short-iso --no-pager --until "$SEARCH_DATE" | grep "usb[0-9]\|usb[0-9][0-9]" > "$RAW_LOG_FILE"

# Format the logs and save to FORMATTED_LOG_FILE
echo "Timestamp        Hostname          Event Type             VendorID   ProductID  bcdDevice  Product           Manufacturer             SerialNumber" > "$FORMATTED_LOG_FILE"
echo "---------------- ---------------- -------------------    ---------  ---------  ---------  ----------------  -----------------------  ----------------" >> "$FORMATTED_LOG_FILE"
awk '{ printf "%-16s %-16s %-22s %-11s %-10s %-10s %-18s %-24s %-20s\n", $1, $2, $3, $5, $6, $7, $9, $10, $11 }' "$RAW_LOG_FILE" >> "$FORMATTED_LOG_FILE"

echo "USB connection logs from previous dates have been collected and saved to $RAW_LOG_FILE and $FORMATTED_LOG_FILE"

