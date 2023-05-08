#!/bin/bash

echo "Linux_Forensic_64.bash for forensics in a Linux 64-bit environment"
echo "by Team_Bocchi_The_Forensic"
echo "Version 0.03b"
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

PS3='Please Select the section You Want to Forensic : '
select section in "ALL" "Active Data" "Inactive Data" "Exit"
do
	if [ "$section" = "ALL" ];then
		for file in Inactive_Scripts/*.bash
			do
				echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
				./"$file"
				echo "-------------------------------------------------------------"
			done
		
		for file in Active_Scripts/*.bash
			do
				echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
				./"$file"
				echo "-------------------------------------------------------------"
			done
	fi
	
	if [ "$section" = "Inactive Data" ];then
		PS3='Please Select the section You want to Forensic in Inactive Data : '
		select intact_section in "ALL" "Metadata Info" "Log File Info" "System/Login Info" "Trash/Recycle bin Info" "Web History Info" "Exit"
		do
			if [ "$inact_section" = "ALL" ];then
				echo "Collection $inact_section..."
				echo
				for file in Inactive_Scripts/*.bash
				do
					echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
					./"$file"
					echo "-------------------------------------------------------------"
				done
				echo "Collection Finished"
			fi

			if [ "$inact_section" = "Metadata Info" ];then       # Forensic Metadata section
				echo "Collecting $inact_section..."
				echo
				echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
				./Scripts/a_metadata.bash
				echo "Collection Finished"
			fi

			if [ "$inact_section" = "Log File Info" ];then       # Forensic Log File section
				echo "Collecting $inact_section..."
				echo
				echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
				./Scripts/b_log.bash
				echo "Collection Finished"
			fi

			if [ "$inact_section" = "System/Login Info" ];then       # Forensic System & Login Information section
				echo "Collecting $inact_section..."
				echo
				echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
				./Scripts/c_systeminfo.bash
				echo "Collection Finished"
			fi

			if [ "$inact_section" = "Trash/Recycle bin Info" ];then       # Forensic Trash File section
				echo "Collecting $inact_section..."
				echo
				echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
				./Scripts/c_trash.bash
				echo "Collection Finished"
			fi

			if [ "$inact_section" = "Web History Info" ];then       # Forensic Web History File section
				echo "Collecting $inact_section..."
				echo
				echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
				./Scripts/d_webhistory.bash
				echo "Collection Finished"
			fi
		done
	fi

	if [ "$section" = "Active Data" ];then
		# Selective statement that selects the area you want to forensics
		PS3='Please Select the section You want to Forensic in Active Data : '
		select act_section in "ALL" "Logon Info" "Network Info" "Processor Info" "Autorun" "System Info" "Exit"
		do
			if [ "$act_section" = "ALL" ];then              # Forensic ALL section
				echo "Collecting $act_section..."
				echo
				for file in Active_Scripts/*.bash
				do
					echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
					./"$file"
					echo "-------------------------------------------------------------"
				done
				echo "Collection Finished"
			fi

			if [ "$act_section" = "Logon Info" ];then       # Forensic Logon section
				echo "Collecting $act_section..."
				echo
				echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
				./Scripts/logon.bash
				echo "Collection Finished"
			fi
		
			if [ "$act_section" = "Network" ];then          # Forensic Network section
				echo "Collecting $act_section..."
				echo
				echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
				./Scripts/network_64.bash
				echo "Collection Finished"
			fi
			
			if [ "$act_section" = "Processor Info" ];then   # Forensic Processor section
				echo "Collecting $act_section..."
				echo
				echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
				./Scripts/processinfo.bash
				echo "Collection Finished"
			fi
			
			if [ "$act_section" = "Autorun" ];then          # Forensic Network section
				echo "Collecting $act_section..."
				echo
				echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
				./Scripts/auto_64.bash
				echo "Collection Finished"
			fi
		
			if [ "$act_section" = "System Info" ];then          # Forensic Network section
				echo "Collecting $act_section..."
				echo
				echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
				./Scripts/sysinfo_64.bash
				echo "Collection Finished"
			fi
			
			if [ "$act_section" = "Exit" ];then             # Exit the program
				echo "Exit the Forensic Program"
				echo
				break
			fi
			
			echo
			continue
		done
	fi
done