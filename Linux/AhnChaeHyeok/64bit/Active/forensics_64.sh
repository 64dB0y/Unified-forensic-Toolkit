#!/bin/bash

chmod +x auto_64.sh
chmod +x logon_64.sh
chmod +x network_64.sh
chmod +x proc_64.sh
chmod +x sysinfo_64.sh

PS3='Please Select the section You want to Forensic : '

select section in "Autorun" "Logon user" "Network" "Processor" "System Info" "Exit"
do
	if [ "$section" = "Autorun" ];then
		echo "Running forensic for $section"
		./auto_64.sh
	fi
	
	if [ "$section" = "Logon user" ];then
		echo "Running forensic for $section"
		./logon_64.sh
	fi
	
	if [ "$section" = "Network" ];then
		echo "Running forensic for $section"
		./network_64.sh
	fi
	
	if [ "$section" = "Processor" ];then
		echo "Running forensic for $section"
		./proc_64.sh
	fi
	
	if [ "$section" = "System Info" ];then
		echo "Running forensic for $section"
		./sysinfo_64.sh
	fi
	
	if [ "$section" = "Exit" ];then
		echo Exit the Forensic Program
		break
	fi
	
	echo  
	continue
done
