#!/bin/bash

# Set the directory to search for files
search_dir=~/abab/REAL/바로가기파일/

# Find all LNK files and store their filenames in an array
lnk_files=($(find "$search_dir" -type f -name "*.lnk" -printf '%p\n'))

# Find all jump list files and store their filenames in an array
jump_list_files=($(find "$search_dir" -type f -name "*.automaticDestinations-ms" -printf '%p\n'))

# Output the list of LNK files and jump list files
echo "LNK files found:"
printf '%s\n' "${lnk_files[@]}"
echo ""
echo "Jump list files found:"
printf '%s\n' "${jump_list_files[@]}"

