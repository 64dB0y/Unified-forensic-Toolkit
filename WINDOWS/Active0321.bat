@echo off
setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set COMPUTER_NAME=%computername%
set REG_DUMP_PATH=%SCRIPT_DIR%%COMPUTER_NAME%\registry_dump
set NETWORK_INFO_PATH=%SCRIPT_DIR%%COMPUTER_NAME%\network_info
set PROCESS_DUMP_PATH=%SCRIPT_DIR%%COMPUTER_NAME%\process_dump
set LOGIN_USER_INFO_PATH=%SCRIPT_DIR%%COMPUTER_NAME%\login_user_info


set /a current_step=0
set /a final_step=4

:display_menu
echo.
echo Select the step you want to perform:
echo ----------------------------------
echo 1. Dump registry and cache
echo 2. Collect network connection information
echo 3. Collect process information
echo 4. Collect login user information
echo a. Perform all steps
echo q. Quit
echo USAGE: 2,3,4

set /p choice=

if "%choice%"=="q" (
exit
)

set "selected_options=%choice%"
if "%choice%"=="a" (
set "selected_options=1 2 3 4"
)

for %%i in (%selected_options%) do (
call :run_step %%i
)

goto end_script

:run_step
if %1==1 (
echo ---------------------------------------
echo Dumping registry and cache...
echo ---------------------------------------
if not exist "%REG_DUMP_PATH%" (
mkdir "%REG_DUMP_PATH%" && echo Created directory: "%REG_DUMP_PATH%"
) else (
echo Directory already exists: "%REG_DUMP_PATH%"
)
reg save HKLM\ "%REG_DUMP_PATH%\hklm.reg" && echo HKLM registry dumped to: "%REG_DUMP_PATH%\hklm.reg"
reg save HKCU\ "%REG_DUMP_PATH%\hkcu.reg" && echo HKCU registry dumped to: "%REG_DUMP_PATH%\hkcu.reg"
reg query HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Lsa\CachedCredentials > "%REG_DUMP_PATH%\cached_credentials.txt" && echo Cached credentials dumped to: "%REG_DUMP_PATH%\cached_credentials.txt"
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList > "%REG_DUMP_PATH%\profiles.txt" && echo Profiles dumped to: "%REG_DUMP_PATH%\profiles.txt"
echo ---------1. Creating Registry and Cache hash file----------
mkdir "%REG_DUMP_PATH%\hash"
certutil -hashfile "%REG_DUMP_PATH%\hklm.reg" md5 > "%REG_DUMP_PATH%\hash\hklm_hash.txt"
certutil -hashfile "%REG_DUMP_PATH%\hklm.reg" sha1 >> "%REG_DUMP_PATH%\hash\hklm_hash.txt"
certutil -hashfile "%REG_DUMP_PATH%\hkcu.reg" md5 > "%REG_DUMP_PATH%\hash\hkcu_hash.txt"
certutil -hashfile "%REG_DUMP_PATH%\hkcu.reg" sha1 >> "%REG_DUMP_PATH%\hash\hkcu_hash.txt"
certutil -hashfile "%REG_DUMP_PATH%\cached_credentials.txt" md5 > "%REG_DUMP_PATH%\hash\cached_credentials_hash.txt"
certutil -hashfile "%REG_DUMP_PATH%\cached_credentials.txt" sha1 >> "%REG_DUMP_PATH%\hash\cached_credentials_hash.txt"
certutil -hashfile "%REG_DUMP_PATH%\profiles.txt" md5 > "%REG_DUMP_PATH%\hash\profiles_hash.txt"
certutil -hashfile "%REG_DUMP_PATH%\profiles.txt" sha1 >> "%REG_DUMP_PATH%\hash\profiles_hash.txt"
echo.
) else if %1==2 (
echo ---------------------------------------
echo Collecting network connection information...
echo ---------------------------------------
if not exist "%NETWORK_INFO_PATH%" (
mkdir "%NETWORK_INFO_PATH%" && echo Created directory: "%NETWORK_INFO_PATH%"
) else (
echo Directory already exists: "%NETWORK_INFO_PATH%"
)
"%SCRIPT_DIR%SysinternalsSuite\tcpvcon64.exe" -a -c /accepteula > "%SCRIPT_DIR%%COMPUTER_NAME%\network_info\tcpvcon.txt"
"%SCRIPT_DIR%Nirsoft\cports-x64\cports.exe" /stext "%SCRIPT_DIR%%COMPUTER_NAME%\network_info\currports.txt"
route print > "%SCRIPT_DIR%%COMPUTER_NAME%\network_info\route.txt"
netsh interface ipv4 show neighbors > "%SCRIPT_DIR%%COMPUTER_NAME%\network_info\ipv4_neighbors.txt"
nbtstat -c > "%SCRIPT_DIR%%COMPUTER_NAME%\network_info\nbtstat.txt"
net use > "%SCRIPT_DIR%%COMPUTER_NAME%\network_info\net_use.txt"
net share > "%SCRIPT_DIR%%COMPUTER_NAME%\network_info\net_share.txt"
net user > "%SCRIPT_DIR%%COMPUTER_NAME%\network_info\net_user.txt"
ipconfig /all > "%SCRIPT_DIR%%COMPUTER_NAME%\network_info\ipconfig.txt"
netstat -anob > "%SCRIPT_DIR%%COMPUTER_NAME%\network_info\netstat.txt"
echo ---------2. Creating Network Information hash file----------
mkdir "%NETWORK_INFO_PATH%\hash"
certutil -hashfile "%NETWORK_INFO_PATH%\tcpvcon.txt" md5 > "%NETWORK_INFO_PATH%\hash\tcpvcon_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\tcpvcon.txt" sha1 >> "%NETWORK_INFO_PATH%\hash\tcpvcon_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\currports.txt" md5 > "%NETWORK_INFO_PATH%\hash\currports_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\currports.txt" sha1 >>"%NETWORK_INFO_PATH%\hash\currports_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\route.txt" md5 > "%NETWORK_INFO_PATH%\hash\route_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\route.txt" sha1 >> "%NETWORK_INFO_PATH%\hash\route_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\ipv4_neighbors.txt" md5 > "%NETWORK_INFO_PATH%\hash\ipv4_neighbors_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\ipv4_neighbors.txt" sha1 >> "%NETWORK_INFO_PATH%\hash\ipv4_neighbors_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\nbtstat.txt" md5 > "%NETWORK_INFO_PATH%\hash\nbtstat_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\nbtstat.txt" sha1 >> "%NETWORK_INFO_PATH%\hash\nbtstat_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\net_use.txt" md5 > "%NETWORK_INFO_PATH%\hash\net_use_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\net_use.txt" sha1 >> "%NETWORK_INFO_PATH%\hash\net_use_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\net_share.txt" md5 > "%NETWORK_INFO_PATH%\hash\net_share_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\net_share.txt" sha1 >> "%NETWORK_INFO_PATH%\hash\net_share_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\net_user.txt" md5 > "%NETWORK_INFO_PATH%\hash\net_user_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\net_user.txt" sha1 >> "%NETWORK_INFO_PATH%\hash\net_user_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\ipconfig.txt" md5 > "%NETWORK_INFO_PATH%\hash\ipconfig_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\ipconfig.txt" sha1 >> "%NETWORK_INFO_PATH%\hash\ipconfig_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\netstat.txt" md5 > "%NETWORK_INFO_PATH%\hash\netstat_hash.txt"
certutil -hashfile "%NETWORK_INFO_PATH%\netstat.txt" sha1 >> "%NETWORK_INFO_PATH%\hash\netstat_hash.txt"
echo.
) else if %1==3 (
echo ---------------------------------------
echo Collecting process information...
echo ---------------------------------------
if not exist "%PROCESS_DUMP_PATH%" (
mkdir "%PROCESS_DUMP_PATH%" && echo Created directory: "%PROCESS_DUMP_PATH%"
) else (
echo Directory already exists: "%PROCESS_DUMP_PATH%"
)
"%SCRIPT_DIR%\SysinternalsSuite\pslist.exe" /accepteula> "%PROCESS_DUMP_PATH%\pslist.txt" && echo Process list dumped to: "%PROCESS_DUMP_PATH%\pslist.txt"
"%SCRIPT_DIR%\SysinternalsSuite\psloglist.exe" -d 30 -s -t * /accepteula> "%PROCESS_DUMP_PATH%\psloglist.txt" && echo Process log dumped to: "%PROCESS_DUMP_PATH%\psloglist.txt"
echo ---------3. Creating Process information hash file----------
mkdir %PROCESS_DUMP_PATH%\hash
certutil -hashfile "%PROCESS_DUMP_PATH%\pslist.txt" md5 > %PROCESS_DUMP_PATH%\hash\pslist_hash.txt
certutil -hashfile "%PROCESS_DUMP_PATH%\pslist.txt" sha1 >> %PROCESS_DUMP_PATH%\hash\pslist_hash.txt
certutil -hashfile "%PROCESS_DUMP_PATH%\psloglist.txt" md5 > %PROCESS_DUMP_PATH%\hash\psloglist_hash.txt
certutil -hashfile "%PROCESS_DUMP_PATH%\psloglist.txt" sha1 >> %PROCESS_DUMP_PATH%\hash\psloglist_hash.txt
echo.
) else if %1==4 (
echo ---------------------------------------
echo Collecting login user information...
echo ---------------------------------------
if not exist "%LOGIN_USER_INFO_PATH%" (
mkdir "%LOGIN_USER_INFO_PATH%" && echo Created directory: "%LOGIN_USER_INFO_PATH%"
) else (
echo Directory already exists: "%LOGIN_USER_INFO_PATH%"
)
net user > "%LOGIN_USER_INFO_PATH%\users.txt" && echo User accounts dumped to: "%LOGIN_USER_INFO_PATH%\users.txt"
net localgroup administrators > "%LOGIN_USER_INFO_PATH%\admin_group.txt" && echo Local administrators group dumped to: "%LOGIN_USER_INFO_PATH%\admin_group.txt"
query user > "%LOGIN_USER_INFO_PATH%\logged_on_users.txt" && echo Logged on users dumped to: "%LOGIN_USER_INFO_PATH%\logged_on_users.txt"
echo ---------4. Creating Login User hash file----------
mkdir %LOGIN_USER_INFO_PATH%\hash
certutil -hashfile "%LOGIN_USER_INFO_PATH%\users.txt" md5 > %LOGIN_USER_INFO_PATH%\hash\users_hash.txt
certutil -hashfile "%LOGIN_USER_INFO_PATH%\users.txt" sha1 >> %LOGIN_USER_INFO_PATH%\hash\users_hash.txt
certutil -hashfile "%LOGIN_USER_INFO_PATH%\admin_group.txt" md5 > %LOGIN_USER_INFO_PATH%\hash\admin_group_hash.txt
certutil -hashfile "%LOGIN_USER_INFO_PATH%\admin_group.txt" sha1 >> %LOGIN_USER_INFO_PATH%\hash\admin_group_hash.txt
certutil -hashfile "%LOGIN_USER_INFO_PATH%\logged_on_users.txt" md5 > %LOGIN_USER_INFO_PATH%\hash\logged_on_users_hash.txt
certutil -hashfile "%LOGIN_USER_INFO_PATH%\logged_on_users.txt" sha1 >> %LOGIN_USER_INFO_PATH%\hash\logged_on_users_hash.txt
echo.
)

set /a current_step+=1

if %current_step%==%final_step% (
    echo All steps completed.
    goto end_script
)


:end_script
echo Script finished.
