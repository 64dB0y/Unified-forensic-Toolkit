@echo off

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0

set /a current_step=0
set /a final_step=6

:display_menu
echo.
echo Select the step you want to perform:
echo ----------------------------------
echo 1. Dump registry and cache
echo 2. Collect network connection information
echo 3. Collect process information
echo 4. Collect login user information
echo 5. Collect system information
echo 6. Collect auto-run items
echo 7. Collect clipboard and scheduled tasks information
echo a. Perform all steps
echo q. Quit

set /p choice=Enter your choice:

if /i "%choice%"=="q" exit
if /i "%choice%"=="a" (
    set /a current_step=1
    set /a final_step=7
) else (
    set /a current_step=%choice%
    set /a final_step=%choice%
)

echo.

:run_step
if %current_step%==1 (
    echo Dumping registry and cache...
    mkdir "%SCRIPT_DIR%SysinternalsSuite\registry_dump"
    reg save HKLM\ hklm.reg
    reg save HKCU\ hkcu.reg
    reg query HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Lsa\CachedCredentials > "%SCRIPT_DIR%SysinternalsSuite\registry_dump\cached_credentials.txt"
    reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList > "%SCRIPT_DIR%SysinternalsSuite\registry_dump\profiles.txt"
    echo.
)
if %current_step%==2 (
    echo Collecting network connection information...
    "%SCRIPT_DIR%SysinternalsSuite\tcpview.exe"
    "%SCRIPT_DIR%Nirsoft\CurrPorts.exe"
    route print
    netsh interface ipv4 show neighbors
    nbtstat -c
    net use
    net share
    net user
    ipconfig /all
    netstat -anob
    echo.
)
if %current_step%==3 (
    echo Collecting process information...
    mkdir "%SCRIPT_DIR%SysinternalsSuite\process_dump"
    "%SCRIPT_DIR%SysinternalsSuite\procexp.exe" /accepteula /saveall "%SCRIPT_DIR%SysinternalsSuite\process_dump\procexp.dump"
    echo.
)
if %current_step%==4 (
    echo Collecting login user information...
    mkdir "%SCRIPT_DIR%SysinternalsSuite\user_info_dump"
    "%SCRIPT_DIR%SysinternalsSuite\procmon.exe" /quiet /backingfile "%SCRIPT_DIR%SysinternalsSuite\user_info_dump\procmon.pml"
    echo.
)
if %current_step%==5 (
    echo Collecting system information...
    systeminfo > "%SCRIPT_DIR%SysinternalsSuite\system_info.txt"
    wevtutil qe System /c:100 /rd:true /f:text > "%SCRIPT_DIR%SysinternalsSuite\system_log.txt"
    reg save HKEY_LOCAL_MACHINE\SOFTWARE "%SCRIPT_DIR%SysinternalsSuite\system_registry.reg"
    echo.
)
if %current_step%==6 (
    echo Collecting auto-run items...
    mkdir "%SCRIPT_DIR%SysinternalsSuite\autoruns"
    "%SCRIPT_DIR%SysinternalsSuite\Autoruns.exe" /accepteula /save "%SCRIPT_DIR%SysinternalsSuite\autoruns\autoruns.arn"
    echo.
)
if %current_step%==7 (
echo Collecting clipboard and scheduled tasks information...
mkdir "%SCRIPT_DIR%SysinternalsSuite\clipboard_tasks"
"%SCRIPT_DIR%SysinternalsSuite\Pclip.exe" > "%SCRIPT_DIR%SysinternalsSuite\clipboard_tasks\clipboard.txt"
schtasks /query /fo LIST /v > "%SCRIPT_DIR%SysinternalsSuite\clipboard_tasks\scheduled_tasks.txt"
echo.
)

if %current_step%==%final_step% (
    echo All steps have been completed.
    echo.
)
