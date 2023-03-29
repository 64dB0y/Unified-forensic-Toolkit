#!/bin/bash

# Enter name and description of the task
read -p "Enter your name : " name
read -p "Enter a description of the task to be performed : " task_desc

# Create a Timestamp
timestamp=$(date +"%Y-%m-%d %T)

# Create a filename based on the timestamp
filename="Forensic_Info.txt"

# Write the user name, task description, timestamp, and hostname(device name) to the file
echo "Name: $name" > "$filename"
echo "Task Description: $task_desc" >> "$filename"
echo "Timestamp: $timestamp" >> "$filename"
echo hostname >> "$filename"

# Permission for scripts and hash value program
chmod +x Scripts/*.bash
chmod 777 hash.exe

# Selective statement that selects the area you want to forensics
PS3='Please Select the section You want to Forensic : '
select section in "ALL" "Logon Info" "Network Info" "Processor Info" "Exit"
do
	if [ "$section" = "ALL" ];then              # Forensic ALL section
		echo "Collecting $section..."
		for file in Scripts/*.bash
		do
		    ./"$file"
		done
		echo "Collection Finished"
		echo
	fi

	if [ "$section" = "Logon Info" ];then       # Forensic Logon section
		echo "Collecting $section..."
		./Scripts/logon.bash
		echo "Collection Finished"
		echo
	fi

	if [ "$section" = "Network" ];then          # Forensic Network section
		echo "Collecting $section..."
		./Scripts/network_64.bash
		echo "Collection Finished"
		echo
	fi

	if [ "$section" = "Processor Info" ];then   # Forensic Processor section
		echo "Collecting $section..."
		./Scripts/processinfo.bash
		echo "Collection Finished"
		echo
	fi

	if [ "$section" = "Exit" ];then             # Exit the program
		echo "Exit the Forensic Program"
		break
	fi

	echo  
	continue
done
