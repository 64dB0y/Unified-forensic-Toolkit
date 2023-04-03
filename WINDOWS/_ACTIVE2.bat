@echo off
setlocal enabledelayedexpansion

:: 초기 설정
echo -------------
echo PATH Settings
echo -------------
echo.
echo.

set CASE=%1
set NAME=%2

set final_step=7
set choice=

set "nirsoft=%~dp0nirsoft"
set "sysinternals=%~dp0sysinternalsSuite"
set "etc=%~dp0etc"
set "hash=%~dp0hash"
set "dump=%~dp0Memory_Dump_Tool"
set "PATH=%PATH%;%nirsoft%;%sysinternals%;%etc%;%hash%;%dump%"


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

:: Timestamp
set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%
set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
set minute=%time:~3,2%
set second=%time:~6,2%
set timestamp=%year%-%month%-%day%_%hour%-%minute%-%second%


:: 현재 시간과 컴퓨터 이름으로 새로운 폴더를 생성함
set foldername=%3%computername%_%timestamp%
mkdir "%foldername%"
echo "%foldername%"
echo.

:: 타임스탬프 저장을 위한 폴더를 생성 
set TimeStamp=%foldername%\TimeStamp.log
echo START TIME : %timestamp%
echo [%timestamp%]START TIME >> %TimeStamp%

:: Input CASE, NAME
:INPUT_CASE
echo [%timestamp%]%CASE% >> %TimeStamp%

:INPUT_NAME
echo [%timestamp%]%NAME% >> %TimeStamp%

:START
echo %CASE% - %NAME% Digital Forensic START
echo .


:: Prepare to collect Active Data
set "volatile_dir=%foldername%\Volatile_Information"
mkdir "%volatile_dir%"
echo Created VOLATILE DIRECTORY 
echo [%timestamp%]Created VOLATILE DIRECTORY >> %TimeStamp%
echo.

:Display_Menu
echo.
echo ====================================
echo Select the step you want to perform:
echo ====================================
echo [0] MEMORY DUMP				- Creates Memory dump
echo [1] REGISTER, CACHE DUMP		- Creates Register, cache dump		
echo [2] NETWORK INFORMATION			- Collects network configuration and connection status
echo [3] PROCESS INFORMATION			- Collects information about running processes and their resource usage
echo [4] LOGON USER INFORMATION		- Collects information about the currently logged in user
echo [5] SYSTEM INFORMATION			- Collects system event logs and registry information
echo [6] AUTORUNS LIST			- Collects a list of programs configured to start automatically during boot
echo [7] TASK SCHEDULAR, CLIPBOARD(TSCB)	- Collects information about scheduled tasks and clipboard history
echo [a] RUN ALL STEPS
echo [q] QUIT
echo ====================================
echo Input Example: 2,3,4
echo.
echo.
set /p choice="You entered : "

if not defined choice (
    goto :Display_Menu
) else (
    setlocal enabledelayedexpansion
    set "steps="
    for %%x in (%choice%) do (
        if /i "%%x"=="q" (
            exit /b
        ) else if /i "%%x"=="a" (
            for /l %%i in (0, 1, %final_step%) do (
                set "steps=!steps! %%i"
            )
        ) else (
            set "steps=!steps! %%x"
        )
    )

    for %%x in (!steps!) do (
        call :run_step_%%x
    )
)

goto :Display_Menu

:run_step_0
:: 0. Memory Dump
echo -----------------------------
echo 0. Dumping Memory...
echo [%timestamp%] Creating Memory Dump START >> %TimeStamp%
echo -----------------------------
echo.

set Memory_Dump_dir=%volatile_dir%\Memory_Dump
mkdir %Memory_Dump_dir%
echo --------------------------
echo CREATE MEMORY_DUMP DIRECTORY
echo [%timestamp%] CREATE MEMORY_DUMP DIRECTORY >> %TimeStamp%
echo ACQUIRING INFORMATION
echo --------------------------
echo.
echo.
echo Dumping RAM...
set /p "ram_dump_tool=Which RAM dump tool to use? (R=RamCapture, W=Winpmem, C=CyLR): "
set "ram_dump_tool=%ram_dump_tool:~,1%"
set /p "UserName=Please Input User_Name which has Administrator priviledge: "
if /I "%ram_dump_tool%"=="R" (
	start "RamCapture" cmd /c runas /user:%UserName% "powershell Start-Process %dump%\Belkasoft-RamCapturer\x64\RamCapture64.exe -Verb runAs"
	REM start "RamCapture" cmd /c runas /user:%UserName% "%dump%\Belkasoft-RamCapturer\x64\RamCapture64.exe"
	REM start "RamCapture" cmd /c "%dump%\Belkasoft-RamCapturer\x64\RamCapture64.exe"
	timeout /t 10
) else if /I "%ram_dump_tool%"=="W" (
	start /wait "Winpmem" cmd /c runas /user:%UserName% "powershell Start-Process %dump%\winpmem\winpmem_mini_x64_rc2.exe %Memory_Dump_dir%\physmem.raw -Verb runAs"
	REM start /wait "Winpmem" cmd /c runas /user:%UserName% "%dump%\winpmem\winpmem_mini_x64_rc2.exe %Memory_Dump_dir%\physmem.raw"
	REM start /wait "Winpmem" cmd /c "%dump%\winpmem\winpmem_mini_x64_rc2.exe %Memory_Dump_dir%\physmem.raw"
	timeout /t 10
) else if /I "%ram_dump_tool%"=="C" (
	REM set /p "result_password=Please Input CyLR result password: "
	REM start "CyLR" cmd /c runas /user:%UserName% "powershell Start-Process %dump%\CyLR\CyLR_64.exe -Verb runAs -ArgumentList '-od %Memory_Dump_dir% -of memory_dump.zip -zp %result_password% -zl 9'"
	REM start /wait "CyLR" cmd /c "%dump%\CyLR\CyLR_64.exe -od %Memory_Dump_dir% -of memory_dump.zip -zp %result_password% -zl 9
	start /wait "CyLR" cmd /c "%dump%\CyLR\CyLR_64.exe -od %Memory_Dump_dir% -of memory_dump.zip -zp L!veF0rens!c -zl 9
	timeout
) else (
	echo There's no other option to dump Memory
)
echo Step completed: %choice%
exit /b


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
echo CREATE REGISTERCACHE DIRECTORY
echo [%timestamp%] CREATE REGISTERCACHE DIRECTORY >> %TimeStamp%
echo ACQUIRING INFORMATION
echo --------------------------
echo.
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
:: echo ACQUIRING BLUESCREEN INFORMATION
%nirsoft%\bluescreenview\BlueScreenView.exe /stext %RegisterCache_dir%\bluescreenview.txt
echo [%timestamp%]ACQUIRING BLUESCREEN INFORMATION >> %TimeStamp%

:: echo Make Hash File
set REGISTRY_HASH=%RegisterCache_dir%\HASH
echo [%timestamp%]REGISTRY HASH DIRECTORY CREATE >> %TimeStamp%
mkdir %REGISTRY_HASH%

:: --------------------
:: SAM FILE HASH
:: --------------------
%hash%\hashdeep64.exe "%RegisterCache_dir%\SAM" > "%REGISTRY_HASH%\SAM_HASH.txt"
echo [%timestamp%] SAM HASH >> %TimeStamp%
:: --------------------
:: SOFTWARE FILE HASH
:: --------------------
%hash%\hashdeep64.exe "%RegisterCache_dir%\SOFTWARE" > "%REGISTRY_HASH%\SOFTWARE_HASH.txt"
echo [%timestamp%] SOFTWARE HASH >> %TimeStamp%
:: --------------------
:: SYSTEM FILE HASH
:: --------------------
%hash%\hashdeep64.exe "%RegisterCache_dir%\SYSTEM" > "%REGISTRY_HASH%\SYSTEM_HASH.txt"
echo [%timestamp%] SYSTEM HASH >> %TimeStamp%

:: --------------------
:: SECURITY FILE HASH
:: --------------------
%hash%\hashdeep64.exe "%RegisterCache_dir%\SECURITY" > "%REGISTRY_HASH%\SECURITY_HASH.txt"
echo [%timestamp%] SECURITY HASH >> %TimeStamp%

:: BLUESCREENVIEW_HASH
%hash%\hashdeep64.exe "%RegisterCache_dir%\bluescreenview.txt" > "%REGISTRY_HASH%\BLUESCREENVIEW_HASH.txt"
echo [%timestamp%] BLUESCREENVIEW HASH >> %TimeStamp%

echo REGISTRY INFORMATION CLEAR 
echo [%timestamp%] REGISTRY INFORMATION CLEAR >> %TimeStamp%
echo.

echo Step completed: %choice%
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
echo [%timestamp%] CREATE NETWORK DIRECTORY >> %TimeStamp%
echo --------------------------
echo CREATE NETWORK DIRECTORY
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

:: ipconfig command
ipconfig /all > "%Network_dir%\ipconfig.txt"
echo [%timestamp%] ipconfig >> %TimeStamp%

:: urlprotocolview  /stext <Filename>	
%nirsoft%\urlprotocolview_u\urlprotocolview.exe /stext "%Network_dir%\urlprotocolview.txt"
echo [%timestamp%] urlprotocolview >> %TimeStamp%

:: cports
%nirsoft%\cports-x64\cports.exe /stext "%Network_dir%\cports.txt"
echo [%timestamp%] cports >> %TimeStamp%

:: TCPLOGVIEW
%nirsoft%\tcplogview-x64\tcplogview /stext "%Network_dir%\tcplogview.txt"
echo [%timestamp%] tcplogview >> %TimeStamp%

%nirsoft%\wifiinfoview-x64\WifiInfoView.exe /stext "%Network_dir%\wifiInfoView.txt
echo [%timestamp%] WifiInfoView >> %TimeStamp%

%nirsoft%\wirelessnetview\WirelessNetView.exe /stext "%Network_dir%\WirelessNetView.txt
echo [%timestamp%] WirelessNetView >> %TimeStamp%

:: echo Network Data collection is complete.
:: echo.
:: echo Make Hash File

set NETWORK_HASH=%Network_dir%\HASH
mkdir %NETWORK_HASH%
echo [%timestamp%] CREATE NETWORK HASH DIRECTORY >> %TimeStamp%
::Hash 
::--------------------------------------------------------------
%hash%\hashdeep64.exe "%Network_dir%\arp.txt" > "%NETWORK_HASH%\arp_hash.txt"
echo [%timestamp%] ARP HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\route.txt" > "%NETWORK_HASH%\route_hash.txt"
echo [%timestamp%] ROUTE HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\netstat.txt" > "%NETWORK_HASH%\netstat_hash.txt"
echo [%timestamp%] NETSTAT HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\net_sessions.txt" > "%NETWORK_HASH%\net_sessions_hash.txt"
echo [%timestamp%] NETSESSION HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\net_file.txt" > "%NETWORK_HASH%\net_file_hash.txt"
echo [%timestamp%] NET FILE HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\net_share.txt" > "%NETWORK_HASH%\net_share_hash.txt"
echo [%timestamp%] NET SHARE HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\arp.txt" > "%NETWORK_HASH%\arp_hash.txt"
echo [%timestamp%] ARP HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\nbtstat_c.txt" > "%NETWORK_HASH%\nbtstat_c_hash.txt"
echo [%timestamp%] NBTSTAT_C HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\nbtstat_s.txt" > "%NETWORK_HASH%\nbtstat_s_hash.txt"
echo [%timestamp%] NBTSTAT_S HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\ipconfig.txt" > "%NETWORK_HASH%\ipconfig_hash.txt"
echo [%timestamp%] IPCONFIG HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\urlprotocolview.txt" > "%NETWORK_HASH%\urlprotocolview_hash.txt"
echo [%timestamp%] URLPROTOCOLVIEW HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\cports.txt" > "%NETWORK_HASH%\cports_hash.txt"
echo [%timestamp%] CPORTS HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\tcplogview.txt" > "%NETWORK_HASH%\tcplogview_hash.txt"
echo [%timestamp%] TCPLOGVIEW HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\wifiInfoView.txt" > "%NETWORK_HASH%\wifiInfoView_hash.txt"
echo [%timestamp%] WIFIINFOVIEW HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Network_dir%\WirelessNetView.txt" > "%NETWORK_HASH%\WirelessNetView_hash.txt"
echo [%timestamp%] WIRELESSNETVIEW HASH >> %TimeStamp%

::--------------------------------------------------------------

echo NETWORK INFORMATION CLEAR
echo [%timestamp%]NETWORK INFORMATION CLEAR >> %TimeStamp%
echo.
echo Step completed: %choice%
exit /b

:run_step_3
echo -----------------------------
echo 3. PROCESS INFORMATION
echo [%timestamp%] PROCESS INFORMATION START >> %TimeStamp%
echo -----------------------------
echo.

set PROCESS_Dir=%volatile_dir%\Process_Information
mkdir %PROCESS_Dir%
echo [%timestamp%] CREATE PROCESS DIRECTORY >> %TimeStamp%
echo --------------------------
echo CREATE PROCESS DIRECTORY
echo.
echo ACQUIRING INFORMATION
echo --------------------------

:: psloglist 
%sysinternals%\psloglist.exe -d 30 -s -t * /accepteula > %PROCESS_Dir%\psloglist.txt
echo [%timestamp%] PSLOGLIST >> %TimeStamp%


:: tasklist - ok 
tasklist -V > %PROCESS_Dir%\tasklist.txt
echo [%timestamp%] TASKLIST >> %TimeStamp%

:: pslist 
%sysinternals%\pslist64.exe /accepteula > %PROCESS_Dir%\pslist.txt
echo [%timestamp%] PSLIST >> %TimeStamp%

:: listdlls - ok
%sysinternals%\Listdlls64.exe /accepteula > %PROCESS_Dir%\listdll.txt 
echo [%timestamp%] LISTDLLS >> %TimeStamp%

::handle - ok 
%sysinternals%\handle64.exe /accepteula > %PROCESS_Dir%\handle.txt
echo [%timestamp%] HANDLE >> %TimeStamp%

:: tasklist /FO TABLE /NH > process_list.txt 
tasklist /FO TABLE /NH > %PROCESS_Dir%\tasklist.txt
echo [%timestamp%] TASKLIST >> %TimeStamp%

:: regdllview64 /stext
%nirsoft%\regdllview-x64\RegDllView.exe /stext %PROCESS_Dir%\regdllview.txt
echo [%timestamp%] REGDLLVIEW >> %TimeStamp%

:: loadeddllsview /stext - ok 
%nirsoft%\loadeddllsview-x64\LoadedDllsView.exe /stext %PROCESS_Dir%\loadeddllsview.txt
echo [%timestamp%] LOADEDDLLSVIEW >> %TimeStamp%

:: driverview /stext - ok
%nirsoft%\driverview-x64\DriverView.exe /stext %PROCESS_Dir%\driveview.txt
echo [%timestamp%] DRIVEVIEW >> %TimeStamp%

:: cprocess - ok 
%nirsoft%\cprocess\CProcess.exe /stext %PROCESS_Dir%\cprocess.txt
echo [%timestamp%] CPROCESS >> %TimeStamp%

:: openedfilesview /scomma
%nirsoft%\ofview-x64\OpenedFilesView.exe /stext %PROCESS_Dir%\openedfilesview.txt
echo [%timestamp%] OPENEDFILESVIEW >> %TimeStamp%

:: opensavefilesview
%nirsoft%\opensavefilesview-x64\OpenSaveFilesView.exe /stext %PROCESS_Dir%\opensavefilesview.txt
echo [%timestamp%] OPENSAVEFILESVIEW >> %TimeStamp%

:: executedprogramslist
%nirsoft%\executedprogramslist\ExecutedProgramsList.exe /stext %PROCESS_Dir%\executedprogramslist.txt
echo [%timestamp%] EXECUTEDPROGRAMSLIST >> %TimeStamp%

:: installedpackagesview
%nirsoft%\installedpackagesview-x64\InstalledPackagesView.exe /stext %PROCESS_Dir%\installedpackagesview.txt
echo [%timestamp%] INSTALLEDPACKAGESVIEW >> %TimeStamp%

:: uninstallview
%nirsoft%\uninstallview-x64\UninstallView.exe /stext %PROCESS_Dir%\uninstallview.txt
echo [%timestamp%] UNINSTALLVIEW >> %TimeStamp%

:: mylastsearch
%nirsoft%\mylastsearch\MyLastSearch.exe /stext %PROCESS_Dir%\mylastsearch.txt
echo [%timestamp%] MYLASTSEARCH >> %TimeStamp%

:: browsers 
%nirsoft%\browseraddonsview-x64\BrowserAddonsView.exe /stext %PROCESS_Dir%\browseraddonsview.txt
echo [%timestamp%] BROWSERADDONSVIEW >> %TimeStamp%

%nirsoft%\browserdownloadsview-x64\BrowserDownloadsView.exe /stext %PROCESS_Dir%\browserdownloadsview.txt
echo [%timestamp%] BROWSERDOWNLOADSVIEW >> %TimeStamp%

%nirsoft%\browsinghistoryview-x64\BrowsingHistoryView.exe /stext %PROCESS_Dir%\browsinghistoryview.txt
echo [%timestamp%] BROWSINGHISTORYVIEW >> %TimeStamp%

::echo Process Data collection is completed
::echo.
::echo Make Hash File

set PROCESS_HASH=%PROCESS_Dir%\HASH
mkdir %PROCESS_HASH%
echo [%timestamp%] CREATE PROCESS HASH DIRECTORY >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\psloglist.txt" > "%PROCESS_HASH%\psloglist_hash.txt"
echo [%timestamp%] PSLOGLIST HASH >> %TimeStamp%
%hash%\hashdeep64.exe "%PROCESS_Dir%\tasklist.txt" > "%PROCESS_HASH%\tasklist_hash.txt"
echo [%timestamp%] TASKLIST HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\pslist.txt" > "%PROCESS_HASH%\pslist_hash.txt"
echo [%timestamp%] PSLIST HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\listdll.txt" > "%PROCESS_HASH%\listdll_hash.txt"
echo [%timestamp%] LISTDLL HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\handle.txt" > "%PROCESS_HASH%\handle_hash.txt"
echo [%timestamp%] HANDLE HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\regdllview.txt" > "%PROCESS_HASH%\regdllview_hash.txt"
echo [%timestamp%] REGDLLVIEW HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\loadeddllsview.txt" > "%PROCESS_HASH%\loadeddllsview_hash.txt"
echo [%timestamp%] LOADEDDLLSVIEW HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\driveview.txt" > "%PROCESS_HASH%\driveview_hash.txt"
echo [%timestamp%] DRIVEVIEW HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\cprocess.txt" > "%PROCESS_HASH%\cprocess_hash.txt"
echo [%timestamp%] CPROCESS HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\openedfilesview.txt" > "%PROCESS_HASH%\openedfilesview_hash.txt"
echo [%timestamp%] OPENEDFILESVIEW HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\opensavefilesview.txt" > "%PROCESS_HASH%\opensavefilesview_hash.txt"
echo [%timestamp%] OPENSAVEFILESVIEW HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\executedprogramslist.txt" > "%PROCESS_HASH%\executedprogramslist_hash.txt"
echo [%timestamp%] EXECUTEDPROGRAMSLIST HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\installedpackagesview.txt" > "%PROCESS_HASH%\installedpackagesview_hash.txt"
echo [%timestamp%] INSTALLEDPACKAGESVIEW HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\uninstallview.txt" > "%PROCESS_HASH%\uninstallview_hash.txt"
echo [%timestamp%] UNINSTALLVIEW HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\mylastsearch.txt" > "%PROCESS_HASH%\mylastsearch_hash.txt"
echo [%timestamp%] MYLASTSEARCH HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\browseraddonsview.txt" > "%PROCESS_HASH%\browseraddonsview_hash.txt"
echo [%timestamp%] BROWSERADDONSVIEW HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\browserdownloadsview.txt" > "%PROCESS_HASH%\browserdownloadsview_hash.txt"
echo [%timestamp%] BROWSERDOWNLOADSVIEW HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%PROCESS_Dir%\browsinghistoryview.txt" > "%PROCESS_HASH%\browsinghistoryview_hash.txt"
echo [%timestamp%] BROWSINGHISTORYVIEW HASH >> %TimeStamp%

echo PROCESS INFORMATION CLEAR
echo [%timestamp%] PROCESS INFORMATION CLEAR >> %TimeStamp%

echo Step completed: %choice%

exit /b

:run_step_4
echo -----------------------------
echo 4. LOGON USER INFORMATION
echo [%timestamp%] LOGON USER INFORMATION START >> %TimeStamp%
echo -----------------------------
echo.

set Logon_Dir=%volatile_dir%\Logon_Information
mkdir %Logon_Dir%
echo [%timestamp%] CREATE LOGON DIRECTORY >> %TimeStamp%
echo --------------------------
echo CREATE LOGON DIRECTORY
echo.
echo ACQUIRING INFORMATION
echo --------------------------

:: psloggedon - ok 
%sysinternals%\PsLoggedon64.exe /accepteula > %Logon_Dir%\psloggedon.txt 
echo [%timestamp%] PSLOGGEDON >> %TimeStamp%

:: logonsessions /accepteula - ok
%sysinternals%\logonsessions64.exe /accepteula > %Logon_Dir%\logonsessions.txt 
echo [%timestamp%] LOGONSESSIONS >> %TimeStamp%

:: net user - ok 
net user > %Logon_Dir%\net_user.txt
echo [%timestamp%] NET USER >> %TimeStamp%

:: winlogonview - ok
%nirsoft%\winlogonview\WinLogOnView.exe /scomma %Logon_Dir%\winlogonview.txt
echo [%timestamp%] WINLOGONVIEW >> %TimeStamp%

::echo Logon Data collection is complete.
::echo.
::echo Make Hash File

set LOGON_HASH=%Logon_Dir%\HASH
mkdir %LOGON_HASH%
echo [%timestamp%] CREATE LOGON HASH DIRECTORY >> %TimeStamp%

%hash%\hashdeep64.exe "%Logon_Dir%\psloggedon.txt" > "%LOGON_HASH%\psloggedon_hash.txt"
echo [%timestamp%] PSLOGGEDON HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Logon_Dir%\logonsessions.txt" > "%LOGON_HASH%\logonsessions_hash.txt"
echo [%timestamp%] LOGONSESSIONS HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Logon_Dir%\net_user.txt" > "%LOGON_HASH%\net_user_hash.txt"
echo [%timestamp%] NET USER HASH >> %TimeStamp%

%hash%\hashdeep64.exe "%Logon_Dir%\winlogonview.txt" > "%LOGON_HASH%\winlogonview_hash.txt"
echo [%timestamp%] WINLOGONVIEW HASH >> %TimeStamp%

echo LOGON INFORMATION CLEAR
echo [%timestamp%] LOGON INFORMATION CLEAR >> %TimeStamp%

echo Step completed: %choice%
exit /b

:run_step_5
echo -----------------------------
echo 5. SYSTEM INFORMATION
echo [%timestamp%] SYSTEM INFORMATION START >> %TimeStamp%
echo -----------------------------
echo.

set SYTEM_INFO_Dir=%volatile_dir%\System_Information
mkdir %SYTEM_INFO_Dir%
echo [%timestamp%] CREATE SYTEM Information Directory >> %TimeStamp%
echo ------------------------------------------
echo CREATE SYTEM Information Directory
echo.
echo ACQUIRING INFORMATION
echo ------------------------------------------
REM Collect system information
systeminfo > "%SYTEM_INFO_Dir%\systeminfo.txt"
echo.
echo.
echo.
echo Start the necessary services required for executing subsequent commands
echo.
net start "Windows Event Collector"
net start "Windows Event Log"
net start "Windows Management Instrumentation"

REM Collect registry information
reg save HKEY_LOCAL_MACHINE\SOFTWARE "%SYTEM_INFO_Dir%\HKLM-Software.hiv"
reg save HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control "%SYTEM_INFO_Dir%\HKLM-System-Control.hiv"
reg save HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services "%SYTEM_INFO_Dir%\HKLM-System-Services.hiv"
reg save HKEY_LOCAL_MACHINE\SECURITY "%SYTEM_INFO_Dir%\HKLM-Security.hiv"
for /f "delims=" %%a in ('reg query HKEY_USERS ^| findstr /v "HKEY_USERS"') do (
    set "subkey=%%a"
    echo Saving !subkey!
    reg save "!subkey!" "%SYSTEM_INFO_Dir%\!subkey:.=!_%timestamp%.hiv" /y
    echo !subkey! registry file dumped to : "%SYSTEM_INFO_Dir%" at [%timestamp%] >> %SYSTEM_INFO_Dir%\%timestamp%_RegistryBackup.log
    echo !subkey! registry file dumped to : "%SYSTEM_INFO_Dir%" at [%timestamp%]
)
echo Above registry files have been saved successfully.



echo Step completed: %choice%
exit /b
:run_step_6
echo -----------------------------
echo 6. AUTORUNS
echo [%timestamp%] AUTORUNS START >> %TimeStamp%
echo -----------------------------
echo.

set Autoruns_Dir=%volatile_dir%\Autoruns_Information
mkdir %Autoruns_Dir%
echo [%timestamp%] CREATE Autoruns DIRECTORY >> %TimeStamp%
echo ----------------------------------
echo CREATE Autoruns DIRECTORY
echo.
echo ACQUIRING INFORMATION
echo ----------------------------------
REM Collect startup programs
reg save HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run "%Autoruns_Dir%\HKLM-Run.reg"
reg save HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run "%Autoruns_Dir%\HKCU-Run.reg"

REM Collect auto start services
sc query type= service state= all > "%Autoruns_Dir%\services.txt"

REM Collect event forwarding subscriptions
wecutil es > "%Autoruns_Dir%\wecutil-es.txt"

:: AutoRunsc 실행 (Sysinternals)
"%sysinternals%\autorunsc.exe" /accepteula -a * -c -ct csv -nobanner > "%SYSTEM_INFO_Dir%\AutoRuns.csv"

:: ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp 경로의 파일 나열
dir /b /a "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" > "%Autoruns_Dir%\Startup_ProgramData.txt"

:: 사용자별 Startup 경로의 파일 나열
for /d %%A in (C:\Users\*) do (
    set "user_startup_path=%%A\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    if exist "!user_startup_path!" (
        echo Listing files in !user_startup_path! >> "%Autoruns_Dir%\Startup_UserPaths.txt"
        dir /b /a "!user_startup_path!" >> "%Autoruns_Dir%\Startup_UserPaths.txt"
    )
)
echo Step completed: %choice%
exit /b
:run_step_7
echo -----------------------------------------------
echo 7. TASK SCHEDULAR and CLIPBOARD(TSCB)
echo [%timestamp%] "TASK SCHEDULAR and CLIPBOARD START" >> %TimeStamp%
echo -----------------------------------------------
echo.

set TSCB_Dir=%volatile_dir%\TSCB_Information
mkdir %TSCB_Dir%
echo [%timestamp%] CREATE TSCB DIRECTORY >> %TimeStamp%
echo -------------------------------
echo CREATE TSCB DIRECTORY
echo.
echo ACQUIRING INFORMATION
echo -------------------------------
REM Collect clipboard information
clip > "%SystemInfo_dir%\clipboard.txt"
REM Collect scheduled tasks information using schtasks
echo Collecting scheduled tasks information...
schtasks /query /fo CSV /v > "%TSCB_Dir%\ScheduledTasks.csv"
echo Scheduled tasks information collected successfully.
echo.
echo Step completed: %choice%
exit /b

:end_script
echo SCRIPT FINISHED
endlocal
exit 