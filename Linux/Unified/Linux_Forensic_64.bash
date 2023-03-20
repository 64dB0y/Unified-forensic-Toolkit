#!/bin/bash

chmod +x logon.bash
chmod +x network_64.bash
chmod +x processinfo.bash

# Selective statement that selects the area you want to forensics
PS3='Please Select the section You want to Forensic : '
select section in "ALL" "Logon Info" "Network Info" "Processor Info"
do
    if [ "$section" = "ALL" ];then              # Forensic ALL section
        echo "Run forensic for $section"
        echo
        ./logon.bash
        ./network_64.bash
        ./processinfo.bash

	if [ "$section" = "Logon Info" ];then       # Forensic Logon section
		echo "Run forensic for $section"
        echo
		./logon.bash
	fi
	
	if [ "$section" = "Network" ];then          # Forensic Network section
		echo "Run forensic for $section"
        echo
		./network_64.bash
	fi
	
	if [ "$section" = "Processor Info" ];then   # Forensic Processor section
		echo "Run forensic for $section"
        echo
		./processinfo.bash
	fi
	
	if [ "$section" = "Exit" ];then             # Exit the program
		echo Exit the Forensic Program
		break
	fi
	
	echo  
	continue
done