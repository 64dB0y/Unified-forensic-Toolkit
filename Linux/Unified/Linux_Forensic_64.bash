#!/bin/bash

chmod +x Scripts/*.bash

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