@echo off

:: 설정
set TARGET_DRIVE=C:
set FORENSIC_TOOL_DIR=tools
set FORECOPY_HANDY_DIR=forecopy_handy
set AUTORUNS_TOOL=%FORENSIC_TOOL_DIR%\autoruns.exe
set FTK_IMAGER_TOOL=%FORENSIC_TOOL_DIR%\ftkimager.exe
set TSK_TOOL=%FORENSIC_TOOL_DIR%\tsk
set AUTOPSY_TOOL=%FORENSIC_TOOL_DIR%\autopsy-4.18.0-win64\bin

:: 결과물이 저장될 디렉토리 설정
set RESULT_DIR=%cd%\result

:: 결과물이 저장될 디렉토리 생성
mkdir %RESULT_DIR%

:: 디스크 이미지 생성
mkdir %RESULT_DIR%\disk_image
%FTK_IMAGER_TOOL% \.%TARGET_DRIVE% %RESULT_DIR%\disk.img

REM Collect MBR and GPT information
echo Collecting MBR information...
dd if=\.\PhysicalDrive0 of=%cd%\MBR.img bs=512 count=1
echo MBR information collected.

echo Collecting GPT information...
diskpart /s %cd%\GPT_script.txt > %cd%\GPT_info.txt
echo GPT information collected.

REM Collect $MFT information
echo Collecting $MFT information...
mkdir %cd%\NTFS_Info
cd /d %cd%\NTFS_Info
mmls \.\PhysicalDrive0 > mmls_info.txt
fsstat -o 63 -f ntfs -D \.\PhysicalDrive0 > fsstat_info.txt
icat -o 63 -f ntfs -r \.\PhysicalDrive0 0 > _MFT.img
cd ..
echo $MFT information collected.

:: 레지스트리 정보 수집
reg save HKLM\system %RESULT_DIR%\system.hive
reg save HKLM\software %RESULT_DIR%\software.hive

REM Collect registry information
echo Collecting registry information...
mkdir %cd%\Reg_Info
cd /d %cd%\Reg_Info
reg save HKLM\SYSTEM system.reg
reg save HKLM\SOFTWARE software.reg
reg save HKLM\SECURITY security.reg
reg save HKLM\SAM sam.reg
reg save HKCU NTUSER.dat
reg save HKCU\Software\Classes UsrClass.dat
cd ..
echo Registry information collected.

REM Collect prefetch and superfetch information
echo Collecting prefetch and superfetch information...
mkdir %cd%\Prefetch_Info
cd /d %cd%\Prefetch_Info
xcopy /y /i %SystemRoot%\System32\winevt\Logs\*.* .
xcopy /y /i %SystemRoot%\System32\LogFiles\*.* .
cd ..
echo Log information collected.

:: Windows 이벤트 로그 정보 수집
mkdir %RESULT_DIR%\EventLog
copy %SystemRoot%\System32\winevt\Logs* %RESULT_DIR%\EventLog

:: cmd 파일 이력 정보 수집
mkdir %RESULT_DIR%\CmdHistory
reg query "HKCU\Software\Microsoft\Command Processor" /v AutoRun > %RESULT_DIR%\CmdHistory\autorun.txt

:: 사용자 계정 정보 수집
mkdir %RESULT_DIR%\UserAccount
net user > %RESULT_DIR%\UserAccount\user.txt
whoami > %RESULT_DIR%\UserAccount\whoami.txt

:: 시스템 정보 수집
mkdir %RESULT_DIR%\SystemInfo
systeminfo > %RESULT_DIR%\SystemInfo\systeminfo.txt

:: Collect log files
echo Collecting log files...
mkdir %RESULT_DIR%\log_files
wevtutil.exe epl System %RESULT_DIR%\log_files\System_log.evtx
wevtutil.exe epl Application %RESULT_DIR%\log_files\Application_log.evtx
wevtutil.exe epl Security %RESULT_DIR%\log_files\Security_log.evtx
wevtutil.exe epl Setup %RESULT_DIR%\log_files\Setup_log.evtx
netsh advfirewall firewall show rule name=all | findstr Rule | findstr -v "System" | findstr -v "Rule Name:" > %RESULT_DIR%\log_files\firewall_rules.txt
wevtutil.exe qe /lf /f:text /rd:true /c:1 /q:"*[System/EventID=4624]" > %RESULT_DIR%\log_files\logon_events.txt
wevtutil.exe qe /lf /f:text /rd:true /c:1 /q:"*[System/EventID=4688]" > %RESULT_DIR%\log_files\process_events.txt
echo Log files collected.

:: Sysinternals Autoruns를 이용한 부팅 프로그램 정보 수집
%AUTORUNS_TOOL% /accepteula %RESULT_DIR%\autoruns.txt

:: 휴지통 정보 수집
mkdir %RESULT_DIR%\RecycleBin
%FORECOPY_HANDY_DIR%\forecopy_handy.exe %TARGET_DRIVE%\$Recycle.Bin %RESULT_DIR%\RecycleBin

:: 브라우저 사용 흔적 수집
mkdir %RESULT_DIR%\BrowserCache
%TSK_TOOL%\fls -r -o 2048 -f ntfs %RESULT_DIR%\disk.img > %RESULT_DIR%\fls-output.txt
%AUTOPSY_TOOL%\bulk_extractor -o %RESULT_DIR%\BrowserCache %RESULT_DIR%\fls-output.txt

:: 임시 파일 정보 수집
%TSK_TOOL%\fls -r -o 2048 -f ntfs %RESULT_DIR%\disk.img > %RESULT_DIR%\fls-output.txt
%AUTOPSY_TOOL%\bulk_extractor -o %RESULT_DIR%\TempFiles %RESULT_DIR%\fls-output.txt

:: 시스템 복원 지점 정보 수집
mkdir %RESULT_DIR%\SysRestorePoint
%TSK_TOOL%\fls -r -o 2048 -f ntfs %RESULT_DIR%\disk.img > %RESULT_DIR%\fls-output.txt
%AUTOPSY_TOOL%\mac-robber -o csv -f %RESULT_DIR%\SysRestorePoint\sys-restore-point-info.csv -r %RESULT_DIR%\fls-output.txt \
%TARGET_DRIVE%\System Volume Information\_restore{*/RP*/snapshot/_REGISTRY_MACHINE_SYSTEM}

:: 외부 저장 매체 정보 수집
mkdir %RESULT_DIR%\ExternalDevice
xcopy %SystemRoot%\Windows\System32\winevt\Logs\* %RESULT_DIR%\ExternalDevice
%AUTORUNS_TOOL% /accepteula %RESULT_DIR%\ExternalDevice\autoruns.txt

:: 바로가기 파일 정보 수집
:: forecopy_handy 바로가기 파일 수집
set TARGET_DIR=%UserProfile%\AppData\Roaming\Microsoft\Windows\Recent
dir /b %TARGET_DIR%\*.lnk > %RESULT_DIR%\forecopy_handy_lnk.txt

:: 점프리스트 정보 수집
set JUMPLIST_DIR=%UserProfile%\AppData\Roaming\Microsoft\Windows\Recent
type %JUMPLIST_DIR%\AutomaticDestinations\*.automaticDestinations-ms >> %RESULT_DIR%\forecopy_handy_jumplist.txt
type %JUMPLIST_DIR%\CustomDestinations\*.customDestinations-ms >> %RESULT_DIR%\forecopy_handy_jumplist.txt

echo 수집이 완료되었습니다. 결과물은 %RESULT_DIR% 디렉토리에서 확인할 수 있습니다.
