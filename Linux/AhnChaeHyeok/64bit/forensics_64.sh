#!/bin/bash

chmod +x auto_64.sh
chmod +x logon_64.sh
chmod +x network_64.sh
chmod +x proc_64.sh
chmod +x sysinfo_64.sh

# 포렌식 하고자 하는 데이터 종류 선택
PS3='Please Select the section You want to Forensic : '

select section in "Autorun" "Logon user" "Network" "Processor" "System Info" "Run all steps" "Exit"
do
	if [ "$section" = "Autorun" ];then		# 자동실행 항목
		echo "Running forensic for $section"
		./auto_64.sh
	fi
	
	if [ "$section" = "Logon user" ];then		# 로그온 정보
		echo "Running forensic for $section"
		./logon_64.sh
	fi
	
	if [ "$section" = "Network" ];then		# 네트워크 정보
		echo "Running forensic for $section"
		./network_64.sh
	fi
	
	if [ "$section" = "Processor" ];then		# 프로세서 정보
		echo "Running forensic for $section"
		./proc_64.sh
	fi
	
	if [ "$section" = "System Info" ];then		# 시스템 정보
		echo "Running forensic for $section"
		./sysinfo_64.sh
	fi
	
	if [ "$section" = "Run all steps" ];then	# 전체 
		echo "Run all steps"
		./auto_64.sh
		./logon_64.sh
		./network_64.sh
		./proc_64.sh
		./sysinfo_64.sh
		
	if [ "$section" = "Exit" ];then			# 프로그램 종료
		echo Exit the Forensic Program
		break
	fi
	
	continue
done
