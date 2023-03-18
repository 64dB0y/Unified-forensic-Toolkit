#!/bin/bash

# Get clipboard history
clipboard_history=$(xclip -selection clipboard -o)

# Get list of scheduled tasks
scheduled_tasks=$(sudo crontab -l)

# Get current date and time
datetime=$(date +"%Y-%m-%d %H:%M:%S")

# Format the output and save to file
printf "Clipboard History:\n%s\n\nScheduled Tasks:\n%s\n\nCollected on: %s\n" "${clipboard_history:-N/A}" "${scheduled_tasks:-N/A}" "$datetime" > system_info.txt
