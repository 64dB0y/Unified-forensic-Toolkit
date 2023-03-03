@echo off

setlocal 
:: 초기 설정
echo ----------------------
echo PATH Settings........
echo ----------------------

set "nirsoft=%~dp0nirsoft"
set "sysinternals=%~dp0sysinternals"
set "etc=%~dp0etc"

set "PATH=%PATH%;%nirsoft%;%sysinternals%;%etc%" 


rem 현재 시각을 구합니다.
set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%
set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
set minute=%time:~3,2%
set second=%time:~6,2%
set timestamp=%year%-%month%-%day%_%hour%-%minute%-%second%

rem 현재 시간과 컴퓨터 이름으로 새로운 폴더를 생성함
set foldername=%computername%_%timestamp%
mkdir "%foldername%"
echo "%foldername%"

rem 활성데이터 수집을 위한 준비 
set "volatile_dir=%foldername%\Volatile_Information"
mkdir "%volatile_dir%"
echo Created Volatile_Dir 


:: -----------------------------------------------------
:: 1. Register, Cache
set "RegisterCache_dir=%volatile_dir%\RegisterCache"
mkdir "%RegisterCache_dir%"
echo Created RegisterCache Dir
echo Acquiring Information...
REM --------------------------------------------
::procdump64.exe /accepteula > %RegisterCache_dir%\procdump.txt
bluescreenview.exe /stext %RegisterCache_dir%\bluescreenview.txt
:: -----------------------------------------------------


:: -----------------------------------------------------
:: 2. Network Information
set "Network_dir=%volatile_dir%\Network_Information"
mkdir "%Network_dir%"
echo Created Network Dir
REM --------------------------------------------
:: arp -a - ok 
arp -a > "%Network_dir%\arp_result.txt"
:: netstat - ok
netstat -ano > "%Network_dir%\netstat_result.txt"
rem netstat 결과를 파일로 저장합니다.

:: Route - ok 
route PRINT > "%Network_dir%\route_result.txt"

:: net command - ok
net sessions > "%Network_dir%\net_sessions.txt"
net file > "%Network_dir%\net_file.txt"
net share > "%Network_dir%\net_share.txt"

:: nbtstat command - ok 
nbtstat -c > "%Network_dir%\nbtstat_c.txt"
nbtstat -s > "%Network_dir%\nbtstat_s.txt"

:: ifconfig command - ok
ipconfig /all > "%Network_dir%"\ipconfig.txt

:: tcpvcon64.exe -> 운영체제 상황에 따라 변환
tcpvcon64.exe -a -c /accepteula > "%Network_dir%\tcpvcon.txt

echo tcpvcon Clear 

REM SmartSniff 패킷 캡처 
REM 캡처 드라이버 필요 -> 배치 스크립트에 포함이 가능 

:: urlprotocolview  /stext <Filename>	
urlprotocolview.exe /stext "%Network_dir%\urlprotocolview.txt
:: cports
cports.exe /stext "%Network_dir%\cports.txt
:: TcpLogVeiw - no 
:: tcplogview64.exe /stext "%Network_dir%\tcplogview.txt


:: wirelessnetview.exe - 보안문제 
:: WirelessKeyView.exe /stext "%Network_dir%\wirelessnetview.txt

:: WifiInfoView - 보이지 않음  
WifiInfoView.exe /stext "%Network_dir%\wifiInfoView.txt

:: WirelessKeyView - 보안 문제 
:: WirelessKeyView.exe /stext "%Network_dir%\WirelessKeyView.txt

:: WirelessNetView - 보이지 않음 
WirelessNetView /stext "%Network_dir%\WirelessNetView.txt

:: netrouteview /scomma

:: networkusageview /scomma

echo Network Data collection is complete.
:: -----------------------------------------------------

:: 메모리 덤프를 위한 공간
:: winpmem.exe 사용 가능 

:: -----------------------------------------------------
:: 3. Process Information
set PROCESS_Dir=%volatile_dir%\Process_Information
mkdir %PROCESS_Dir%
echo Process Information Acquiring...

:: tasklist - ok 
tasklist -V > %PROCESS_Dir%\tasklist.txt

:: pslist 
pslist64 /accepteula > %PROCESS_Dir%\pslist.txt

:: listdlls - ok
Listdlls64 /accepteula > %PROCESS_Dir%\listdll.txt 

::handle - ok 
handle.exe /accepteula > %PROCESS_Dir%\handle.txt

:: tasklist /FO TABLE /NH > process_list.txt 
tasklist /FO TABLE /NH > %PROCESS_Dir%\tasklist.txt

:: regdllview64 /stext
regdllview64 /stext %PROCESS_Dir%\regdllview.txt

:: injecteddll /stext - 64비트x

:: loadeddllsview /stext - ok 
loadeddllsview64 /stext %PROCESS_Dir%\loadeddllsview.txt

:: driverview /stext - ok
driveview64 /stext %PROCESS_Dir%\driveview.txt

:: cprocess - ok 
cprocess /stext %PROCESS_Dir%\cprocess.txt

:: - procinterrogate -list -md5 -ver -o

:: openedfilesview /scomma
openedfilesview /stext %PROCESS_Dir%\openedfilesview.txt

:: opensavefilesview
opensavefilesview /stext %PROCESS_Dir%\opensavefilesview.txt

:: executedprogramslist
executedprogramslist /stext %PROCESS_Dir%\executedprogramslist.txt

:: installedpackagesview
installedpackagesview /stext %PROCESS_Dir%\installedpackagesview.txt

:: uninstallview
uninstallview /stext %PROCESS_Dir%\uninstallview.txt

:: mylastsearch
mylastsearch /stext %PROCESS_Dir%\mylastsearch.txt

:: browsers 
browseraddonsview /stext %PROCESS_Dir%\browseraddonsview.txt
browserdownloadsview /stext %PROCESS_Dir%\browserdownloadsview.txt
browsinghistoryview /stext %PROCESS_Dir%\browsinghistoryview.txt

echo Process Data collection is complete.
:: -----------------------------------------------------


:: -----------------------------------------------------
:: 4. Logon Users
set Logon_Dir=%volatile_dir%\Logon_Information
mkdir %Logon_Dir%
echo Logon Information Acquiring...

:: psloggedon - ok 
psloggedon64 /accepteula > %Logon_Dir%\psloggedon.txt 

:: logonsessions /accepteula - ok
logonsessions64 /accepteula > %Logon_Dir%\logonsessions.txt 

:: net user - ok 
net user > %Logon_Dir%\net_user.txt

:: winlogonview - ok
winlogonview /scomma %Logon_Dir%\winlogonview.txt

echo Logon Data collection is complete.
:: -----------------------------------------------------


:: -----------------------------------------------------
:: 5. System info
set SystemInfo_Dir=%volatile_dir%\System_Information
mkdir %SystemInfo_Dir%
echo System Information Acquiring...

::psinfo 
psinfo /accepteula > %SystemInfo_Dir%\psinfo.txt

:: disk volume information
psinfo -d > %SystemInfo_Dir%\psinfo_d.txt

:: installed applications information
psinfo -s > %SystemInfo_Dir%\psinfo_s.txt

:: installed hotfixes information
psinfo -h > %SystemInfo_Dir%\psinfo_h.txt

:: Using systeminfo Command
systeminfo > %SystemInfo_Dir%\systeminfo.txt

:: Windows Update Information
winupdatesview /stext %SystemInfo_Dir%\winupdatesview.txt

:: turned on times view - ok
turnedontimesview /stext %SystemInfo_Dir%\turnedontimesview.txt

:: lastactivityview - ok
lastactivityview /stext %SystemInfo_Dir%\lastactivityview.txt

:: Applied Group Policies - ok
gplist > %SystemInfo_Dir%\gplist.txt

:: Applied RSoP(Resultant Set of Policy) Group Policies
:: for Windows Server
:: gpresult /Z
::gpresult /Z > %_SYSTEM_DIR%\gpresult_Z.txt

:: Configured Services - ok
PsService64 /accepteula > %SystemInfo_Dir%\psservice64.txt

:: uninstallview
uninstallview /stext  %SystemInfo_Dir%\uninstallview.txt


echo System Data collection is complete.
:: -----------------------------------------------------


:: -----------------------------------------------------
:: 6. Autoruns
set Autoruns_Dir=%volatile_dir%\Autoruns_Information
mkdir %Autoruns_Dir%
echo Autoruns Data Acquiring...

autorunsc64.exe /accepteula > %Autoruns_Dir%\autorunsc.txt

echo Autoruns Data collection is complete.
:: -----------------------------------------------------


:: -----------------------------------------------------
:: 7. ClipBoard, Scheduler 
::pclip.exe > pclip.txt
set etc_Dir=%volatile_dir%\ClipBoard_Scheduler 
mkdir %etc_Dir%
echo ClipBoard_Scheduler Data Acquiring...

taskschedulerview /stext > %etc_Dir%\taskschedulerview.txt

pclip > %etc_Dir%\pclip.txt

::browseraddonsview 
echo Etc Data collection is complete.
:: -----------------------------------------------------
:: -----------------------------------------------------
:: -----------------------------------------------------


:: NON_VOLATILE DATA 
:: -----------------------------------------------------
:: 파일 시스템 메타데이터 - ok
:: 레지스트리 하이브 파일 - ok
:: 프리패치 / 슈퍼패치 파일 -
:: 이벤트 로그 - ok
:: 휴지통 정보 %SystemRoot%Recycle.Bin
:: 브라우저 사용 정보 웹 아티팩트 %UserProfile%\AppData\Local\Microsoft\Windows\WebCache\WebCacheV01.dat

:: 임시 파일 : %SystemDrive%$LogFile, %SystemDrive%\Extend\UsnJrnl\$J

:: 시스템 복원 지점 
	:: takeown /F "C:\System Volume Information" /R /A
	:: 명령프롬프트에 권한을 부여 한 뒤 수집이 가능함
	
:: 외부 저장매체 - 이벤트로그 수집 시 같이 수집 ok 
:: 바로가기 - ok
echo Start Acquiring NON_VOLATILE DATA
set NONVALATILE_DIR=%foldername%\NONVALATILE
mkdir %NONVALATILE_DIR%

:: MBR
set MBR_DIR=%NONVALATILE_DIR%\MBR
mkdir %MBR_DIR%
dd if=\\.\PhysicalDrive0 of=%MBR_DIR%\MBR bs=512 count=1


:: VBR 
set VBR_DIR=%NONVALATILE_DIR%\VBR
mkdir %VBR_DIR%
forecopy_handy -f %SystemDrive%\$Boot %VBR_DIR%


:: $MFT
set MFT_DIR=%NONVALATILE_DIR%\MFT_DIR
mkdir %MFT_DIR%
forecopy_handy -m %MFT_DIR%

:: $LogFile
set FileSystemLog=%NONVALATILE_DIR%\FSLOG
mkdir %FileSystemLog% 
forecopy_handy -f %SystemDrive%\$LogFile %FileSystemLog%

:: REGISTRY
:: -g option : SAM, SYSTEM, SECURITY, SOFTWARE, DEFAULT, NTUSER.DAT 획득 
forecopy_handy -g %NONVALATILE_DIR%

:: EVENT LOGS - ok 
:: -e option : Event Log 획득 
forecopy_handy -e %NONVALATILE_DIR%

:: Prefatch or Superfatch
forecopy_handy -p %NONVALATILE_DIR%

:: RECENT LNKs and JUMPLIST
forecopy_handy -r "%AppData%\microsoft\windows\recent" %NONVALATILE_DIR%

:: SYSTEM32/drivers/etc files
forecopy_handy -t %NONVALATILE_DIR%
	
:: systemprofile (\Windows\system32\config\systemprofile)
forecopy_handy -r "%SystemRoot%\system32\config\systemprofile" %NONVALATILE_DIR%

:: IE Artifacts
forecopy_handy -i %NONVALATILE_DIR%
	
:: Firefox Artifacts
forecopy_handy -x %NONVALATILE_DIR%	

:: Chrome Artifacts
forecopy_handy -c %NONVALATILE_DIR%
	
:: IconCache
set ICONCACHE=%NONVALATILE_DIR%\iconcache
mkdir %ICONCACHE%

forecopy_handy -f %LocalAppData%\IconCache.db %ICONCACHE%	
	
:: Thumbcache
forecopy_handy -r "%LocalAppData%\microsoft\windows\explorer" %NONVALATILE_DIR%	
	
:: Downloaded Program Files
forecopy_handy -r "%SystemRoot%\Downloaded Program Files" %NONVALATILE_DIR%	
	
:: Java IDX cache
forecopy_handy -r "%UserProfile%\AppData\LocalLow\Sun\Java\Deployment" %NONVALATILE_DIR%	
	
:: WER (Windows Error Reporting)
forecopy_handy -r "%LocalAppData%\Microsoft\Windows\WER" %NONVALATILE_DIR%
	
:: Windows Timeline
forecopy_handy -r "%LocalAppData%\ConnectedDevicesPlatform" %NONVALATILE_DIR%
	
:: Windows Search Database
forecopy_handy -r "%ProgramData%\Microsoft\Search\Data\Applications\Windows" %NONVALATILE_DIR%


echo ----------------------
echo End...
echo ----------------------

endlocal
