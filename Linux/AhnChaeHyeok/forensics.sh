#!/bin/bash

uname -m

PS3='Please Select the section You want to Forensic : '

select section in "Autorun" "Logon user" "Network" "Processor" "System Info" "Exit"
do
	if [ "$section" = "Autorun" ];then
		echo "Running forensic for $section"
		chmod +x auto.sh
		./auto.sh
		date >> hash.txt
		echo    >> hash.txt
	fi
	
	if [ "$section" = "Logon user" ];then
		echo "Running forensic for $section"
		chmod +x logon.sh
		./logon.sh
		date >> hash.txt
		echo    >> hash.txt
	fi
	
	if [ "$section" = "Network" ];then
		echo "Running forensic for $section"
		chmod +x network.sh
		./network.sh
		date >> hash.txt
		echo    >> hash.txt
	fi
	
	if [ "$section" = "Processor" ];then
		echo "Running forensic for $section"
		chmod +x proc.sh
		./proc.sh
		date >> hash.txt
		echo    >> hash.txt
	fi
	
	if [ "$section" = "System Info" ];then
		echo "Running forensic for $section"
		chmod +x sysinfo.sh
		./sysinfo.sh
		date >> hash.txt
		echo    >> hash.txt
	fi
	
	if [ "$section" = "Exit" ];then
		echo Exit the Forensic Program
		break
	fi
	
	continue
done
