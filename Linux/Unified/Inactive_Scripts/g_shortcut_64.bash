#!/bin/bash

echo "Timestamp for Shortcut files" >> ../mnt2/Forensic_Info.txt
timestamp=$(date +"%Y-%m-%d %T")
echo "Shortcut file Script Execution Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/shortcut
timestamp=$(date +"%Y-%m-%d %T")
echo "Shortcut file Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/shortcut/metadata
timestamp=$(date +"%Y-%m-%d %T")
echo "Shortcut file metadata Directory Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

mkdir ../mnt2/shortcut/hash
timestamp=$(date +"%Y-%m-%d %T")
echo "Shortcut Hash Directory Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

grep /bin/bash /etc/passwd | cut -f1 -d: >> userlist.txt	# Save user list

file_path="./userlist.txt"
while IFS= read -r line
do
  if [ ${line} != "root" ];then	# Copy Shortcut from each user's directory
  	# Collect all .desktop files in the ~/.local/share/applications directory
	echo "Collecting .desktop files in $line/.local/share/applications directory..."
	cp -R /home/$line/.local/share/applications/*.desktop ../mnt2/shortcut
	timestamp=$(date +"%Y-%m-%d %T")
	echo "$line/.local/share/applications shortcut file copy Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

	# Collect the recently-used.xbel file in the ~/.local/share directory
	echo "Collecting recently-used.xbel file in $line/.local/share directory..."
	cp /home/$line/.local/share/recently-used.xbel ../mnt2/shortcut/recently-used.xbel
	timestamp=$(date +"%Y-%m-%d %T")
	echo "$line/.local/share/recently-used.xbel shortcut file copy Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

	# Collect all files in the ~/Desktop directory
	echo "Collecting shortcut files in $line/Desktop directory..."
	cp -R /home/$line/Desktop/* ../mnt2/shortcut
	timestamp=$(date +"%Y-%m-%d %T")
	echo "$line/Desktop shortcut file copy Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
  fi
done < "$file_path"

rm userlist.txt

# Collect metadata for each file
echo "Collecting metadata for collected files..."
for file in ../mnt2/shortcut*
do
    echo "Collecting metadata for file: $file"
    stat $file > ../mnt2/shortcut/metadata/$(basename $file).metadata.txt
done
timestamp=$(date +"%Y-%m-%d %T")
echo "shortcut file metadata Timestamp : $timestamp" >> ../mnt2/Forensic_Info.txt

for file in ../mnt2/shortcut*					# Obtain the hash value for each result file
do
	echo "$file" >> ../mnt2/shortcut/hash/hash.txt
	sudo ./hash.exe "$file" >> ../mnt2/shortcut/hash/hash.txt
	echo >> ../mnt2/shortcut/hash/hash.txt
done

for file in ../mnt2/shortcut/metatdata/*.txt
do
	echo "$file" >> ../mnt2/shortcut/hash/hash.txt
	sudo ./hash.exe "$file" >> ../mnt2/shortcut/hash/hash.txt
	echo >> ../mnt2/shortcut/hash/hash.txt
done

timestamp=$(date +"%Y-%m-%d %T")
echo "Temporary hash.txt Timtestamp : $timestamp" >> ../mnt2/Forensic_Info.txt
date >> ../mnt2/shortcut/hash/hash.txt
echo    >> ../mnt2/shortcut/hash/hash.txt

echo "Forensic collection for shortcut files completed."
