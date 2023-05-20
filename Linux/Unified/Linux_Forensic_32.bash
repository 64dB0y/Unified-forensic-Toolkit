#!/bin/bash

# Selective statement that selects the area you want to forensics
PS3='Please Select the section You want to Forensic in Active Data : '
select act_section in "ALL" "Logon Info" "Network Info" "Processor Info" "Autorun" "System Info" "Exit"
do
	if [ "$act_section" = "ALL" ];then              # Forensic ALL section
		echo "Collecting $act_section..."
		echo
		for file in Active_Scripts/*32.bash
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
		./Active_Scripts/b_logon_32.bash
		echo "Collection Finished"
	fi

	if [ "$act_section" = "Network" ];then          # Forensic Network section
		echo "Collecting $act_section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Active_Scripts/c_network_32.bash
		echo "Collection Finished"
	fi
	
	if [ "$act_section" = "Processor Info" ];then   # Forensic Processor section
		echo "Collecting $act_section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Active_Scripts/d_processinfo_32.bash
		echo "Collection Finished"
	fi
	
	if [ "$act_section" = "Autorun" ];then          # Forensic Network section
		echo "Collecting $act_section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Active_Scripts/e_auto_32.bash
		echo "Collection Finished"
	fi

	if [ "$act_section" = "System Info" ];then          # Forensic Network section
		echo "Collecting $act_section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Active_Scripts/f_sysinfo_32.bash
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

PS3='Please Select the section You want to Forensic in Inactive Data : '
select inact_section in "ALL" "Metadata Info" "Log File Info" "System/Login Info" "Trash/Recycle bin Info" "Web History Info" "Temporary File Info" "Shortcut Info" "External Storage Info" "Exit"
do
	if [ "$inact_section" = "ALL" ];then
		echo "Collection $inact_section..."
		echo
		for file in Inactive_Scripts/*32.bash
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
		./Inactive_Scripts/a_metadata_32.bash
		echo "Collection Finished"
	fi

	if [ "$inact_section" = "Log File Info" ];then       # Forensic Log File section
		echo "Collecting $inact_section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Inactive_Scripts/b_log_32.bash
		echo "Collection Finished"
	fi

	if [ "$inact_section" = "System/Login Info" ];then       # Forensic System & Login Information section
		echo "Collecting $inact_section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Inactive_Scripts/c_systeminfo_32.bash
		echo "Collection Finished"
	fi

	if [ "$inact_section" = "Trash/Recycle bin Info" ];then       # Forensic Trash File section
		echo "Collecting $inact_section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Inactive_Scripts/d_trash_32.bash
		echo "Collection Finished"
	fi

	if [ "$inact_section" = "Web History Info" ];then       # Forensic Web History File section
		echo "Collecting $inact_section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Inactive_Scripts/e_webhistory_32.bash
		echo "Collection Finished"
	fi
	
	if [ "$inact_section" = "Temporary File Info" ];then       # Forensic Temporary File section
		echo "Collecting $inact_section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Inactive_Scripts/f_tmpfile_32.bash
		echo "Collection Finished"
	fi
	
	if [ "$inact_section" = "Shortcut Info" ];then       # Forensic Shortcut section
		echo "Collecting $inact_section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Inactive_Scripts/g_shortcut_32.bash
		echo "Collection Finished"
	fi
	
	if [ "$inact_section" = "External Storage Info" ];then       # Forensic External Storage File section
		echo "Collecting $inact_section..."
		echo
		echo "-------------------------------------------------------------" >> ../mnt2/Forensic_Info.txt
		./Inactive_Scripts/h_ExStorage_32.bash
		echo "Collection Finished"
	fi
	
	if [ "$inact_section" = "Exit" ];then             # Exit the program
		echo "Exit the Forensic Program"
		echo
		break
	fi
done

