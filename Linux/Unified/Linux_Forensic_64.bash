#!/bin/bash

echo "Linux_Forensic_64.bash for forensics in a Linux 64-bit environment"
echo "by Team_Bocchi_The_Forensic"
echo "Version 0.02b"
echo

# Create a Timestamp
timestamp=$(date +"%Y-%m-%d %T")
echo "Timestamp : $timestamp" > ../mnt2/Forensic_Info.txt
echo "Timestamp has been saved in Forensic_Info.txt"
echo

# Enter name, description and hostname of the task
read -p "Enter your name : " name
read -p "Enter a description of the task to be performed : " task_desc
hostname=$(hostname)

# Write the user name, task description, timestamp, and hostname(device name) to the file
echo "Name : $name" >> ../mnt2/Forensic_Info.txt
echo "Task Description : $task_desc" >> ../mnt2/Forensic_Info.txt
echo "Hostname : $hostname" >> ../mnt2/Forensic_Info.txt
echo "Name, task description and hostname has been saved"
echo
cat ../mnt2/Forensic_Info.txt
echo

# Permission for scripts and hash value program
chmod +x Scripts/*.bash
chmod 777 hash.exe

# Selective statement that selects the area you want to forensics
PS3='Please Select the section You want to Forensic : '
select section in "ALL" "Logon Info" "Network Info" "Processor Info" "Autorun" "System Info" "Exit"
do
	if [ "$section" = "ALL" ];then              # Forensic ALL section
		echo "Collecting $section..."
		echo
		for file in Scripts/*.bash
		do
			echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
			./"$file"
			echo "-------------------------------------------------------------"
		done
		echo "Collection Finished"
	fi

	if [ "$section" = "Logon Info" ];then       # Forensic Logon section
		echo "Collecting $section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Scripts/logon.bash
		echo "Collection Finished"
	fi
	
	if [ "$section" = "Network" ];then          # Forensic Network section
		echo "Collecting $section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Scripts/network_64.bash
		echo "Collection Finished"
	fi
	
	if [ "$section" = "Processor Info" ];then   # Forensic Processor section
		echo "Collecting $section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Scripts/processinfo.bash
		echo "Collection Finished"
	fi
	
	if [ "$section" = "Autorun" ];then          # Forensic Network section
		echo "Collecting $section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Scripts/auto_64.bash
		echo "Collection Finished"
	fi
	
	if [ "$section" = "System Info" ];then          # Forensic Network section
		echo "Collecting $section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Scripts/sysinfo_64.bash
		echo "Collection Finished"
	fi
	
	if [ "$section" = "Exit" ];then             # Exit the program
		echo "Exit the Forensic Program"
		echo
		break
	fi
	
	echo
	continue
done
