@echo off

setlocal 
:: 초기 설정
echo -------------
echo PATH Settings
echo -------------
echo.
echo.

set CASE=""
set NAME=""


set /a current_step=0
set /a final_step=4

set "nirsoft=%~dp0nirsoft"
set "sysinternals=%~dp0sysinternals"
set "etc=%~dp0etc"
set "hash=%~dp0hash"
set "PATH=%PATH%;%nirsoft%;%sysinternals%;%etc%;%hash%"


echo -----------------Architecture Detection-----------------
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo 64-bit operating system detected.
    set "path=%path%;%~dp0x64"
) else if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    echo 32-bit operating system detected.
    set "path=%path%;%~dp0x86"
) else (
    echo Unknown architecture detected.
)
echo --------------------------------------------------------
echo.

:: 현재 시각을 구하기 
set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%
set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
set minute=%time:~3,2%
set second=%time:~6,2%
set timestamp=%year%-%month%-%day%_%hour%-%minute%-%second%

:: 현재 시간과 컴퓨터 이름으로 새로운 폴더를 생성함
set foldername=%computername%_%timestamp%
mkdir "%foldername%"
echo "%foldername%"
echo.

:: 타임스탬프 저장을 위한 폴더를 생성 
set TimeStamp=%foldername%\TimeStamp.log
echo START TIME : %timestamp%
echo [%timestamp%]START TIME >> %TimeStamp%

:: 케이스 입력을 받음
:: 입력하지 않았다면 계속 입력을 받도록 대기 
:INPUT_CASE
set /p CASE= CASE INPUT : || GOTO:INPUT_CASE
echo [%timestamp%]%CASE% >> %TimeStamp%

:INPUT_NAME
set /p NAME= NAME INPUT : || GOTO:INPUT_NAME
echo [%timestamp%]%NAME% >> %TimeStamp%

:START
echo %CASE% - %NAME% Digital Forensic START
echo .


:: 활성데이터 수집을 위한 준비 
set "volatile_dir=%foldername%\Volatile_Information"
mkdir "%volatile_dir%"
echo Created VOLATILE DIRECTORY 
echo [%timestamp%]Created VOLATILE DIRECTORY >> %TimeStamp%
echo.

:Display_Menu
echo.
echo ------------------------------------
echo Select the step you want to perform:
echo ------------------------------------
echo.
echo 1. Dump registry and cache
echo 2. Collect network connection information
echo 3. Collect process information
echo 4. Collect login user information
echo a. Perform all steps
echo q. Quit
echo.
echo Example: 2,3,4

echo.
:prompt
set execute_all_labels=0
set /p choice="Enter your choice: "
echo.
echo You entered %choice%
echo [%timestamp%] CHOICE SELECTED %choice% >> %TimeStamp%


if /i "%choice%"=="q" (
    echo [%timestamp%] SELECT CHOICE Q >> %TimeStamp%
    exit /b
)

if /i "%choice%"=="a" (
    echo [%timestamp%] SELECT CHOICE A >> %TimeStamp%
    set execute_all_labels=1
)

if "%execute_all_labels%"=="1" (
    call :run_step_1
    call :run_step_2
    call :run_step_3
    call :run_step_4
) else (
    call :run_step_%choice%
)

goto :prompt

:run_step_1
:: 1. Register, Cache
echo -----------------------------
echo 1. Dumping registry and cache...
echo [%timestamp%] REGISTRY CACHE INFORMATION START >> %TimeStamp%
echo -----------------------------
echo.

set RegisterCache_dir=%volatile_dir%\RegisterCache
mkdir %RegisterCache_dir%
echo --------------------------
echo CREATED REGISTERCACHE DIRECTORY
echo [%timestamp%] CREATED REGISTERCACHE DIRECTORY >> %TimeStamp%
echo ACQUIRING INFORMATION
echo --------------------------
echo.

reg save HKEY_LOCAL_MACHINE\SOFTWARE "%RegisterCache_dir%\SOFTWARE" && echo SOFTWARE registry file dumped to : "%RegisterCache_dir%"
echo [%timestamp%] REG SAVE SOFTWARE >> %TimeStamp%
reg save HKEY_LOCAL_MACHINE\SAM "%RegisterCache_dir%\SAM" && echo SAM registry file dumped to : "%RegisterCache_dir%"
echo [%timestamp%] REG SAVE SAM >> %TimeStamp%
reg save HKEY_LOCAL_MACHINE\SYSTEM "%RegisterCache_dir%\SYSTEM" && echo SYSTEM registry file dumped to : "%RegisterCache_dir%"
echo [%timestamp%] REG SAVE SYSTEM >> %TimeStamp%
reg save HKEY_LOCAL_MACHINE\SECURITY "%RegisterCache_dir%\SECURITY" &&  echo SECURITY registry file dumped to : "%RegisterCache_dir%"
echo [%timestamp%] REG SAVE SECURITY >> %TimeStamp%

:: BLUESCREENVIEW
echo ACQUIRING BLUESCREEN INFORMATION
echo [%timestamp%]ACQUIRING BLUESCREEN INFORMATION >> %TimeStamp%
bluescreenview.exe /stext %RegisterCache_dir%\bluescreenview.txt

echo Make Hash File
set REGISTRY_HASH=%RegisterCache_dir%\HASH
echo [%timestamp%]REGISTRY HASH DIRECTORY CREATE >> %TimeStamp%
mkdir %REGISTRY_HASH%

:: --------------------
:: SAM FILE HASH
:: --------------------
hashdeep64 "%RegisterCache_dir%\SAM" > "%REGISTRY_HASH%\SAM_HASH.txt"
echo [%timestamp%]CREATE SAM HASH >> %TimeStamp%
:: --------------------
:: SOFTWARE FILE HASH
:: --------------------
hashdeep64 "%RegisterCache_dir%\SOFTWARE" > "%REGISTRY_HASH%\SOFTWARE_HASH.txt"
echo [%timestamp%]CREATE SOFTWARE HASH >> %TimeStamp%
:: --------------------
:: SYSTEM FILE HASH
:: --------------------
hashdeep64 "%RegisterCache_dir%\SYSTEM" > "%REGISTRY_HASH%\SYSTEM_HASH.txt"
echo [%timestamp%]CREATE SYSTEM HASH >> %TimeStamp%

:: --------------------
:: SECURITY FILE HASH
:: --------------------
hashdeep64 "%RegisterCache_dir%\SECURITY" > "%REGISTRY_HASH%\SECURITY_HASH.txt"
echo [%timestamp%]CREATE SECURITY HASH >> %TimeStamp%

:: BLUESCREENVIEW_HASH
hashdeep64 "%RegisterCache_dir%\bluescreenview.txt" > "%REGISTRY_HASH%\BLUESCREENVIEW_HASH.txt"
echo [%timestamp%]CREATE BLUESCREENVIEW HASH >> %TimeStamp%

echo REGISTRY INFORMATION CLEAR 
echo [%timestamp%]REGISTRY INFORMATION CLEAR >> %TimeStamp%
echo.
set /a current_step+=1
echo %current_step%

if %current_step%==%final_step% (
    echo All steps completed.
    goto end_script
)
exit /b 

:run_step_2
:: 2. Network Information
echo -----------------------------
echo 2. NETWORK INFORMATION
echo [%timestamp%] NETWORK INFORMATION START >> %TimeStamp%
echo -----------------------------
echo.

set "Network_dir=%volatile_dir%\Network_Information"
mkdir "%Network_dir%"
echo [%timestamp%] CREATED NETWORK DIRECTORY >> %TimeStamp%
echo --------------------------
echo CREATED NETWORK DIRECTORY
echo.
echo ACQUIRING INFORMATION
echo --------------------------

arp -a > "%Network_dir%\arp.txt"
echo [%timestamp%] arp  >> %TimeStamp%

route PRINT > "%Network_dir%\route.txt"
echo [%timestamp%] route >> %TimeStamp%

netstat -ano > "%Network_dir%\netstat.txt"
echo [%timestamp%] netstat >> %TimeStamp%

:: net command 
net sessions > "%Network_dir%\net_sessions.txt"
echo [%timestamp%] net sessions >> %TimeStamp%

net file > "%Network_dir%\net_file.txt"
echo [%timestamp%] net file >> %TimeStamp%

net share > "%Network_dir%\net_share.txt"
echo [%timestamp%] net share >> %TimeStamp%


:: nbtstat command 
nbtstat -c > "%Network_dir%\nbtstat_c.txt"
echo [%timestamp%] nbtstat -c >> %TimeStamp%

nbtstat -s > "%Network_dir%\nbtstat_s.txt"
echo [%timestamp%] nbtstat -s >> %TimeStamp%

:: ifconfig command
ipconfig /all > "%Network_dir%\ipconfig.txt"
echo [%timestamp%] ipconfig >> %TimeStamp%

:: urlprotocolview  /stext <Filename>	
urlprotocolview /stext "%Network_dir%\urlprotocolview.txt"
echo [%timestamp%] urlprotocolview >> %TimeStamp%

:: cports
cports /stext "%Network_dir%\cports.txt"
echo [%timestamp%] cports >> %TimeStamp%

:: TCPLOGVIEW
tcplogview /stext "%Network_dir%\tcplogview.txt"
echo [%timestamp%] tcplogview >> %TimeStamp%

WifiInfoView.exe /stext "%Network_dir%\wifiInfoView.txt
echo [%timestamp%] WifiInfoView >> %TimeStamp%

WirelessNetView /stext "%Network_dir%\WirelessNetView.txt
echo [%timestamp%] WirelessNetView >> %TimeStamp%

:: echo Network Data collection is complete.
:: echo.
:: echo Make Hash File

set NETWORK_HASH=%Network_dir%\HASH
mkdir %NETWORK_HASH%
echo [%timestamp%] CREATE NETWORK HASH DIRECTORY >> %TimeStamp%
::Hash 
::--------------------------------------------------------------
hashdeep64 "%Network_dir%\arp.txt" > "%NETWORK_HASH%\arp_hash.txt"
echo [%timestamp%] ARP HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\route.txt" > "%NETWORK_HASH%\route_hash.txt"
echo [%timestamp%] ROUTE HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\netstat.txt" > "%NETWORK_HASH%\netstat_hash.txt"
echo [%timestamp%] NETSTAT HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\net_sessions.txt" > "%NETWORK_HASH%\net_sessions_hash.txt"
echo [%timestamp%] NETSESSION HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\net_file.txt" > "%NETWORK_HASH%\net_file_hash.txt"
echo [%timestamp%] NET FILE HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\net_share.txt" > "%NETWORK_HASH%\net_share_hash.txt"
echo [%timestamp%] NET SHARE HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\arp.txt" > "%NETWORK_HASH%\arp_hash.txt"
echo [%timestamp%] ARP HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\nbtstat_c.txt" > "%NETWORK_HASH%\nbtstat_c_hash.txt"
echo [%timestamp%] NBTSTAT_C HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\nbtstat_s.txt" > "%NETWORK_HASH%\nbtstat_s_hash.txt"
echo [%timestamp%] NBTSTAT_S HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\ipconfig.txt" > "%NETWORK_HASH%\ipconfig_hash.txt"
echo [%timestamp%] IPCONFIG HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\urlprotocolview.txt" > "%NETWORK_HASH%\urlprotocolview_hash.txt"
echo [%timestamp%] URLPROTOCOLVIEW HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\cports.txt" > "%NETWORK_HASH%\cports_hash.txt"
echo [%timestamp%] CPORTS HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\tcplogview.txt" > "%NETWORK_HASH%\tcplogview_hash.txt"
echo [%timestamp%] TCPLOGVIEW HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\wifiInfoView.txt" > "%NETWORK_HASH%\wifiInfoView_hash.txt"
echo [%timestamp%] WIFIINFOVIEW HASH >> %TimeStamp%

hashdeep64 "%Network_dir%\WirelessNetView.txt" > "%NETWORK_HASH%\WirelessNetView_hash.txt"
echo [%timestamp%] WIRELESSNETVIEW HASH >> %TimeStamp%

::--------------------------------------------------------------

set /a current_step+=1
echo %current_step%

if %current_step%==%final_step% (
    echo All steps completed.
    goto end_script
)
exit /b

:run_step_3
echo -----------------------------
echo 3. PROCESS INFORMATION
echo -----------------------------
:: 3. Process Information
set PROCESS_Dir=%volatile_dir%\Process_Information
mkdir %PROCESS_Dir%
echo Process Directory Create

:: psloglist 
psloglist -d 30 -s -t * /accepteula > %PROCESS_Dir%\psloglist.txt

:: tasklist - ok 
tasklist -V > %PROCESS_Dir%\tasklist.txt

:: pslist 
pslist /accepteula > %PROCESS_Dir%\pslist.txt

:: listdlls - ok
Listdlls /accepteula > %PROCESS_Dir%\listdll.txt 

::handle - ok 
handle /accepteula > %PROCESS_Dir%\handle.txt

:: tasklist /FO TABLE /NH > process_list.txt 
tasklist /FO TABLE /NH > %PROCESS_Dir%\tasklist.txt

:: regdllview64 /stext
regdllview /stext %PROCESS_Dir%\regdllview.txt

:: loadeddllsview /stext - ok 
loadeddllsview64 /stext %PROCESS_Dir%\loadeddllsview.txt

:: driverview /stext - ok
driveview64 /stext %PROCESS_Dir%\driveview.txt

:: cprocess - ok 
cprocess /stext %PROCESS_Dir%\cprocess.txt

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

echo Process Data collection is completed
echo.
echo Make Hash File

set PROCESS_HASH=%PROCESS_Dir%\HASH
mkdir %PROCESS_HASH%

hashdeep64 "%PROCESS_Dir%\psloglist.txt" > "%PROCESS_HASH%\psloglist_hash.txt"
hashdeep64 "%PROCESS_Dir%\tasklist.txt" > "%PROCESS_HASH%\tasklist_hash.txt"
hashdeep64 "%PROCESS_Dir%\pslist.txt" > "%PROCESS_HASH%\pslist_hash.txt"
hashdeep64 "%PROCESS_Dir%\listdll.txt" > "%PROCESS_HASH%\listdll_hash.txt"
hashdeep64 "%PROCESS_Dir%\handle.txt" > "%PROCESS_HASH%\handle_hash.txt"
hashdeep64 "%PROCESS_Dir%\tasklist.txt" > "%PROCESS_HASH%\tasklist_hash.txt"
hashdeep64 "%PROCESS_Dir%\regdllview.txt" > "%PROCESS_HASH%\regdllview_hash.txt"
hashdeep64 "%PROCESS_Dir%\loadeddllsview.txt" > "%PROCESS_HASH%\loadeddllsview_hash.txt"
hashdeep64 "%PROCESS_Dir%\driveview.txt" > "%PROCESS_HASH%\driveview_hash.txt"
hashdeep64 "%PROCESS_Dir%\cprocess.txt" > "%PROCESS_HASH%\cprocess_hash.txt"
hashdeep64 "%PROCESS_Dir%\openedfilesview.txt" > "%PROCESS_HASH%\openedfilesview_hash.txt"
hashdeep64 "%PROCESS_Dir%\opensavefilesview.txt" > "%PROCESS_HASH%\opensavefilesview_hash.txt"
hashdeep64 "%PROCESS_Dir%\executedprogramslist.txt" > "%PROCESS_HASH%\executedprogramslist_hash.txt"
hashdeep64 "%PROCESS_Dir%\installedpackagesview.txt" > "%PROCESS_HASH%\installedpackagesview_hash.txt"
hashdeep64 "%PROCESS_Dir%\uninstallview.txt" > "%PROCESS_HASH%\uninstallview_hash.txt"
hashdeep64 "%PROCESS_Dir%\mylastsearch.txt" > "%PROCESS_HASH%\mylastsearch_hash.txt"
hashdeep64 "%PROCESS_Dir%\browseraddonsview.txt" > "%PROCESS_HASH%\browseraddonsview_hash.txt"
hashdeep64 "%PROCESS_Dir%\browserdownloadsview.txt" > "%PROCESS_HASH%\browserdownloadsview_hash.txt"
hashdeep64 "%PROCESS_Dir%\browsinghistoryview.txt" > "%PROCESS_HASH%\browsinghistoryview_hash.txt"

set /a current_step+=1
echo %current_step%

if %current_step%==%final_step% (
    echo All steps completed.
    goto end_script
)
exit /b

:run_step_4
echo -----------------------------
echo 4. LOGON USER INFORMATION
echo -----------------------------
echo.
set Logon_Dir=%volatile_dir%\Logon_Information
mkdir %Logon_Dir%
echo Logon Information Acquiring...
echo.
:: psloggedon - ok 
psloggedon /accepteula > %Logon_Dir%\psloggedon.txt 

:: logonsessions /accepteula - ok
logonsessions /accepteula > %Logon_Dir%\logonsessions.txt 

:: net user - ok 
net user > %Logon_Dir%\net_user.txt

:: winlogonview - ok
winlogonview /scomma %Logon_Dir%\winlogonview.txt

echo Logon Data collection is complete.
echo.
echo Make Hash File

set LOGON_HASH=%Logon_Dir%\HASH
mkdir %LOGON_HASH%

hashdeep64 "%Logon_Dir%\psloggedon.txt" > "%LOGON_HASH%\psloggedon_hash.txt"
hashdeep64 "%Logon_Dir%\logonsessions.txt" > "%LOGON_HASH%\logonsessions_hash.txt"
hashdeep64 "%Logon_Dir%\net_user.txt" > "%LOGON_HASH%\net_user_hash.txt"
hashdeep64 "%Logon_Dir%\winlogonview.txt" > "%LOGON_HASH%\winlogonview_hash.txt"


set /a current_step+=1
echo %current_step%

if %current_step%==%final_step% (
    echo All steps completed.
    goto end_script
)
exit /b

:end_script
echo Script finished.
exit 
endlocal
