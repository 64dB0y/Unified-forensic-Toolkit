#!/bin/bash

# 해당 기기의 x86 bit 확인
uname -m

# 포렌식 하고자 하는 데이터 종류 선택
PS3='Please Select the section You want to Forensic : '

select section in "Autorun" "Logon user" "Network" "Processor" "System Info" "Exit"
do
	if [ "$section" = "Autorun" ];then		# 자동실행 항목
		echo "Running forensic for $section"
		chmod +x auto.sh
		./auto.sh
		date >> hash.txt
		echo    >> hash.txt
	fi
	
	if [ "$section" = "Logon user" ];then		# 로그온 정보
		echo "Running forensic for $section"
		chmod +x logon.sh
		./logon.sh
		date >> hash.txt
		echo    >> hash.txt
	fi
	
	if [ "$section" = "Network" ];then		# 네트워크 정보
		echo "Running forensic for $section"
		chmod +x network.sh
		./network.sh
		date >> hash.txt
		echo    >> hash.txt
	fi
	
	if [ "$section" = "Processor" ];then		# 프로세서 정보
		echo "Running forensic for $section"
		chmod +x proc.sh
		./proc.sh
		date >> hash.txt
		echo    >> hash.txt
	fi
	
	if [ "$section" = "System Info" ];then		# 시스템 정보
		echo "Running forensic for $section"
		chmod +x sysinfo.sh
		./sysinfo.sh
		date >> hash.txt
		echo    >> hash.txt
	fi
	
	if [ "$section" = "Exit" ];then			# 프로그램 종료
		echo Exit the Forensic Program
		break
	fi
	
	continue
done
