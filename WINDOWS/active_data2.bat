@echo off
setlocal enabledelayedexpansion

:: Initial settings
echo -------------
echo PATH Settings
echo -------------
echo.
echo.

set CASE=%1
set NAME=%2
set "CASE=%CASE: =_%"
set "NAME=%NAME: =_%"
set final_step=7
set choice=

set "nirsoft=%~dp0nirsoft"
set "sysinternals=%~dp0sysinternalsSuite"
set "etc=%~dp0etc"
set "hash=%~dp0hash"
set "dump=%~dp0Memory_Dump_Tool"
set "PATH=%PATH%;%nirsoft%;%sysinternals%;%etc%;%hash%;%dump%;"


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

:: Create new directory with current time, host name
if "%~3"=="" (
    set foldername=%computername%_%timestamp%
) else (
    set foldername=%3
)
if not exist "%foldername%" (
    mkdir "%foldername%"
    echo "created %foldername%"
) else (
    echo Folder "%foldername%" already exists. Skipping creation.
)
echo.

:: create directory to save timestamp
set _TimeStamp=%foldername%\TimeStamp.log
echo START TIME : %timestamp%
echo [%timestamp%] Active Script START TIME >> %_TimeStamp%

:: Input CASE, NAME
:INPUT_CASE
echo [%timestamp%]%CASE% >> %_TimeStamp%

:INPUT_NAME
echo [%timestamp%]%NAME% >> %_TimeStamp%

:START
echo %CASE% - %NAME% Active Data Collection Begins >> %_TimeStamp%
echo .


:: Prepare to collect Active Data
set "volatile_dir=%foldername%\Volatile_Information"
mkdir "%volatile_dir%"
echo Created VOLATILE DIRECTORY 
echo [%timestamp%]Created VOLATILE DIRECTORY >> %_TimeStamp%
echo.

:: Naming conventions for variables in each architecture
set RamCapture=
set Winpmem=
set CyLR=
set pslist=
set psexec=
set psloglist=
set Listdlls=
set handle=
set PsLoggedon=
set logonsessions=
set autorunsc=
set hashdeep=
set cports=
set tcplogview=
set wifiinfoview=
set regdllview=
set loadeddllsview=
set driverview=
set ofview=
set opensavefilesview=
set InstalledPackagesView=
set UninstallView=
set BrowserAddonsView=
set BrowserDownloadsView=
set BrowsingHistoryView=
set bluescreenview=
if %PROCESSOR_ARCHITECTURE%==AMD64 (
  set RamCapture=%dump%\Belkasoft-RamCapturer\x64\RamCapture64.exe
  set Winpmem=%dump%\winpmem\winpmem_mini_x64_rc2.exe
  set CyLR=%dump%\CyLR\CyLR_64.exe
  set pslist=%sysinternals%\pslist64.exe
  set psexec=%sysinternals%\PsExec64.exe
  set psloglist=%sysinternals%\psloglist64.exe
  set Listdlls=%sysinternals%\Listdlls64.exe
  set handle=%sysinternals%\handle64.exe
  set PsLoggedon=%sysinternals%\PsLoggedon64.exe
  set logonsessions=%sysinternals%\logonsessions64.exe
  set autorunsc=%sysinternals%\autorunsc64.exe
  set hashdeep=%hash%\hashdeep64.exe
  set cports=%nirsoft%\cports-x64
  set tcplogview=%nirsoft%\tcplogview-x64
  set wifiinfoview=%nirsoft%\wifiinfoview-x64
  set regdllview=%nirsoft%\regdllview-x64
  set loadeddllsview=%nirsoft%\loadeddllsview-x64
  set driverview=%nirsoft%\driverview-x64
  set ofview=%nirsoft%\ofview-x64
  set opensavefilesview=%nirsoft%\opensavefilesview-x64
  set InstalledPackagesView=%nirsoft%\installedpackagesview-x64
  set UninstallView=%nirsoft%\uninstallview-x64
  set BrowserAddonsView=%nirsoft%\BrowserAddonsView-x64
  set BrowserDownloadsView=%nirsoft%\browserdownloadsview-x64
  set BrowsingHistoryView=%nirsoft%\browsinghistoryview-x64
  set bluescreenview=%nirsoft%\bluescreenview-x64
) else (
  set RamCapture=%dump%\Belkasoft-RamCapturer\x86\RamCapture.exe
  set Winpmem=%dump%\winpmem\winpmem_mini_x86.exe
  set CyLR=%dump%\CyLR\CyLR_32.exe
  set pslist=%sysinternals%\pslist.exe
  set psexec=%sysinternals%\PsExec.exe
  set psloglist=%sysinternals%\psloglist.exe
  set Listdlls=%sysinternals%\Listdlls.exe
  set handle=%sysinternals%\handle.exe
  set PsLoggedon=%sysinternals%\PsLoggedon.exe
  set logonsessions=%sysinternals%\logonsessions.exe
  set autorunsc=%sysinternals%\autorunsc.exe
  set hashdeep=%hash%\hashdeep.exe
  set cports=%nirsoft%\cports
  set tcplogview=%nirsoft%\tcplogview
  set wifiinfoview=%nirsoft%\wifiinfoview
  set regdllview=%nirsoft%\regdllview
  set loadeddllsview=%nirsoft%\loadeddllsview
  set driverview=%nirsoft%\driverview
  set ofview=%nirsoft%\ofview
  set opensavefilesview=%nirsoft%\opensavefilesview
  set InstalledPackagesView=%nirsoft%\installedpackagesview
  set UninstallView=%nirsoft%\uninstallview
  set BrowserAddonsView=%nirsoft%\BrowserAddonsView
  set BrowserDownloadsView=%nirsoft%\browserdownloadsview
  set BrowsingHistoryView=%nirsoft%\browsinghistoryview
  set bluescreenview=%nirsoft%\bluescreenview
)

:Display_Menu
echo.
echo ====================================
echo Select the step you want to perform:
echo ====================================
echo [0] MEMORY DUMP				- Creates Memory dump
echo [1] Virtual Memory DUMP		        - Creates Virtual Memory dump		
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
            echo %CASE% - %NAME% Active Data Collection finished >> %_TimeStamp%
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
call :LogStep
echo -----------------------------
echo 0. Dumping Memory...
echo [%timestamp%] Creating Memory Dump START >> %_TimeStamp%
echo -----------------------------
echo.

set Memory_Dump_dir=%volatile_dir%\Memory_Dump
mkdir %Memory_Dump_dir%
echo --------------------------
echo CREATE MEMORY_DUMP DIRECTORY
echo [%timestamp%] CREATE MEMORY_DUMP DIRECTORY >> %_TimeStamp%
echo ACQUIRING INFORMATION
echo --------------------------
echo.
set PHYSICAL_MEMORY_HASH=%Memory_Dump_dir%\HASH
mkdir %PHYSICAL_MEMORY_HASH%
echo [%timestamp%] CREATE PHYSICAL MEMORY HASH DIRECTORY >> %_TimeStamp%
echo.
echo Dumping RAM...

:ram_dump_loop
echo.
echo.

echo Which RAM dump tool to use?
echo R - RamCapture
echo W - Winpmem
echo C - CyLR
echo Q - quit

choice /C RWCQ /N /M "Select one of the options: "

if errorlevel 4 goto quit_ram_dump
if errorlevel 3 goto cylr_ram_dump
if errorlevel 2 goto winpmem_ram_dump
if errorlevel 1 goto ramcapture_ram_dump

:ramcapture_ram_dump
:: To Hash RamCapture result file
set current_date=%date:~0,4%%date:~5,2%%date:~8,2%
echo ***********************************************************************
echo.
echo Attention - Please input following path on RamCapture:
echo.
echo %Memory_Dump_dir%
echo (Make sure to input the path without line breaks)
echo.
echo ***********************************************************************
echo.
"%psexec%" -accepteula -i -s cmd.exe /c "call cd %Memory_Dump_dir% & %RamCapture%"
echo [%timestamp%] RamCapture Finished >> %_TimeStamp%
echo Please wait, this may take some time - Calculating the hash values for the recently created dump file
%hashdeep% "%Memory_Dump_dir%\%current_date%.mem" > "%PHYSICAL_MEMORY_HASH%\RamCapture_hash.txt"
echo [%timestamp%] RamCapture HASH >> %_TimeStamp%
timeout /t 10
goto ram_dump_loop

:winpmem_ram_dump
set /p "user_id=Please input the user ID of someone with administrator privileges: "
set /p "user_pw=Please input the password for the user with administrator privileges (leave empty if none): "
if not defined user_pw (
        "%psexec%" -u %user_id% -accepteula -i -s cmd.exe /c "call %Winpmem% %Memory_Dump_dir%\physmem.raw"
) else (
    "%psexec%" -u %user_id% -p %user_pw% -accepteula -i -s cmd.exe /c "call %Winpmem% %Memory_Dump_dir%\physmem.raw"
)
echo [%timestamp%] Winpmem Finished >> %_TimeStamp%
%hashdeep% "%Memory_Dump_dir%\physmem.raw" > "%PHYSICAL_MEMORY_HASH%\physmem_hash.txt"
echo [%timestamp%] Winpmem HASH >> %_TimeStamp%
timeout /t 10
goto ram_dump_loop

:cylr_ram_dump
setlocal enabledelayedexpansion
set "result_password="
echo You must not input following symbols: ^< ^> ^^ ^& ^| '^ ^" ^` 
:set_password
set /p "result_password=Please Input CyLR result password: "
set invalid=0
if "!result_password!"=="" (
    set invalid=1
) else (
for /l %%i in (0,1,9) do (
    set "char=!result_password:~%%i,1!"
    if "!char!"=="<" set invalid=1
    if "!char!"==">" set invalid=1
    if "!char!"=="^" set invalid=1
    if "!char!"=="&" set invalid=1
    if "!char!"=="|" set invalid=1
    if "!char!"=="'" set invalid=1
    if "!char!"=="`" set invalid=1
    if "!char!"=="""" set invalid=1
    if !invalid!==1 goto check_password
    )
)
:check_password
if !invalid!==1 (
    echo "There's unacceptable symbols or empty password, plz retype"
    goto set_password
) else (
    echo Currently Password entered: !result_password!
)

:confirm_password
set "confirm_password="
set /p "confirm_password=Please Confirm CyLR result password: "
if "!confirm_password!"=="!result_password!" (
    echo Passwords match
) else (
    echo Passwords do not match, please try again
    goto set_password
)
"%psexec%" -accepteula -i -s cmd.exe /c "call %CyLR% --usnjrnl -od %Memory_Dump_dir% -of memory_dump.zip -zp !result_password! -zl 9"
echo [%timestamp%] CyLR Finished >> %_TimeStamp%
%hashdeep% "%Memory_Dump_dir%\memory_dump.zip" > "%PHYSICAL_MEMORY_HASH%\memory_dump_hash.txt"
echo [%timestamp%] CyLR HASH >> %_TimeStamp%
timeout /t 10
goto ram_dump_loop

:quit_ram_dump
echo You chose to quit: Q
echo There's no other option to dump Memory
goto memory_dump_finished

:memory_dump_finished
echo [%timestamp%] Memory Dump Finished >> %_TimeStamp%

exit /b

:run_step_1
:: 1. Virtual Memory Dump
call :LogStep
echo -----------------------------
echo 1. Dumping Virtual memory...
echo [%timestamp%] Virtual memory START >> %_TimeStamp%
echo -----------------------------
echo.

set Virtual_Memory_dir=%volatile_dir%\Virtual_Memory
mkdir %Virtual_Memory_dir%
echo --------------------------
echo CREATE Virtual_Memory DIRECTORY
echo [%timestamp%] CREATE Virtual_Memory DIRECTORY >> %_TimeStamp%
echo ACQUIRING INFORMATION
echo --------------------------
echo.
echo.
echo [%timestamp%] Dumping Virtual Memory >> %_TimeStamp%

:: To get the session ID
for /f "tokens=4" %%i in ('tasklist /nh /fi "imagename eq cmd.exe" /fi "sessionname eq console"') do set sessionId=%%i

"%psexec%" -accepteula -i %sessionId% -s cmd.exe /c "call %dump%\1_Virtual_Memory_dump.bat %sysinternals% %Virtual_Memory_dir% %_TimeStamp% %hash%"
echo.
echo [%timestamp%] Virtual Memory Dump Completed >> %_TimeStamp%
echo Step completed: %choice%
exit /b 

:run_step_2
:: 2. Network Information
call :LogStep
echo -----------------------------
echo 2. NETWORK INFORMATION
echo [%timestamp%] NETWORK INFORMATION START >> %_TimeStamp%
echo -----------------------------
echo.

set "Network_dir=%volatile_dir%\Network_Information"
mkdir "%Network_dir%"
echo [%timestamp%] CREATE NETWORK DIRECTORY >> %_TimeStamp%
echo --------------------------
echo CREATE NETWORK DIRECTORY
echo.
echo ACQUIRING INFORMATION
echo --------------------------

arp -a > "%Network_dir%\arp.txt"
echo [%timestamp%] arp  >> %_TimeStamp%

route PRINT > "%Network_dir%\route.txt"
echo [%timestamp%] route >> %_TimeStamp%

netstat -ano > "%Network_dir%\netstat.txt"
echo [%timestamp%] netstat >> %_TimeStamp%

:: net command 
net sessions > "%Network_dir%\net_sessions.txt"
echo [%timestamp%] net sessions >> %_TimeStamp%

net file > "%Network_dir%\net_file.txt"
echo [%timestamp%] net file >> %_TimeStamp%

net share > "%Network_dir%\net_share.txt"
echo [%timestamp%] net share >> %_TimeStamp%


:: nbtstat command 
nbtstat -c > "%Network_dir%\nbtstat_c.txt"
echo [%timestamp%] nbtstat -c >> %_TimeStamp%

nbtstat -s > "%Network_dir%\nbtstat_s.txt"
echo [%timestamp%] nbtstat -s >> %_TimeStamp%

:: ipconfig command
ipconfig /all > "%Network_dir%\ipconfig.txt"
echo [%timestamp%] ipconfig >> %_TimeStamp%

:: urlprotocolview  /stext <Filename>	
%nirsoft%\urlprotocolview_u\urlprotocolview.exe /stext "%Network_dir%\urlprotocolview.txt"
echo [%timestamp%] urlprotocolview >> %_TimeStamp%

%cports%\cports.exe /stext "%Network_dir%\cports.txt"
echo [%timestamp%] cports >> %_TimeStamp%

%tcplogview%\tcplogview.exe /stext "%Network_dir%\tcplogview.txt"
echo [%timestamp%] tcplogview >> %_TimeStamp%

%wifiinfoview%\WifiInfoView.exe /stext "%Network_dir%\wifiInfoView.txt
echo [%timestamp%] WifiInfoView >> %_TimeStamp%

%nirsoft%\wirelessnetview\WirelessNetView.exe /stext "%Network_dir%\WirelessNetView.txt
echo [%timestamp%] WirelessNetView >> %_TimeStamp%

:: echo Network Data collection is complete.
:: echo.
:: echo Make Hash File

set NETWORK_HASH=%Network_dir%\HASH
mkdir %NETWORK_HASH%
echo [%timestamp%] CREATE NETWORK HASH DIRECTORY >> %_TimeStamp%
::Hash 
::--------------------------------------------------------------
%hashdeep% "%Network_dir%\arp.txt" > "%NETWORK_HASH%\arp_hash.txt"
echo [%timestamp%] ARP HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\route.txt" > "%NETWORK_HASH%\route_hash.txt"
echo [%timestamp%] ROUTE HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\netstat.txt" > "%NETWORK_HASH%\netstat_hash.txt"
echo [%timestamp%] NETSTAT HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\net_sessions.txt" > "%NETWORK_HASH%\net_sessions_hash.txt"
echo [%timestamp%] NETSESSION HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\net_file.txt" > "%NETWORK_HASH%\net_file_hash.txt"
echo [%timestamp%] NET FILE HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\net_share.txt" > "%NETWORK_HASH%\net_share_hash.txt"
echo [%timestamp%] NET SHARE HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\arp.txt" > "%NETWORK_HASH%\arp_hash.txt"
echo [%timestamp%] ARP HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\nbtstat_c.txt" > "%NETWORK_HASH%\nbtstat_c_hash.txt"
echo [%timestamp%] NBTSTAT_C HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\nbtstat_s.txt" > "%NETWORK_HASH%\nbtstat_s_hash.txt"
echo [%timestamp%] NBTSTAT_S HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\ipconfig.txt" > "%NETWORK_HASH%\ipconfig_hash.txt"
echo [%timestamp%] IPCONFIG HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\urlprotocolview.txt" > "%NETWORK_HASH%\urlprotocolview_hash.txt"
echo [%timestamp%] URLPROTOCOLVIEW HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\cports.txt" > "%NETWORK_HASH%\cports_hash.txt"
echo [%timestamp%] CPORTS HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\tcplogview.txt" > "%NETWORK_HASH%\tcplogview_hash.txt"
echo [%timestamp%] TCPLOGVIEW HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\wifiInfoView.txt" > "%NETWORK_HASH%\wifiInfoView_hash.txt"
echo [%timestamp%] WIFIINFOVIEW HASH >> %_TimeStamp%

%hashdeep% "%Network_dir%\WirelessNetView.txt" > "%NETWORK_HASH%\WirelessNetView_hash.txt"
echo [%timestamp%] WIRELESSNETVIEW HASH >> %_TimeStamp%

::--------------------------------------------------------------

echo NETWORK INFORMATION CLEAR
echo [%timestamp%]NETWORK INFORMATION CLEAR >> %_TimeStamp%
echo.
echo Step completed: %choice%
exit /b

:run_step_3
call :LogStep
echo -----------------------------
echo 3. PROCESS INFORMATION
echo [%timestamp%] PROCESS INFORMATION START >> %_TimeStamp%
echo -----------------------------
echo.

set PROCESS_Dir=%volatile_dir%\Process_Information
mkdir %PROCESS_Dir%
echo [%timestamp%] CREATE PROCESS DIRECTORY >> %_TimeStamp%
echo --------------------------
echo CREATE PROCESS DIRECTORY
echo.
echo ACQUIRING INFORMATION
echo --------------------------

set PROCESS_HASH=%PROCESS_Dir%\HASH
mkdir %PROCESS_HASH%
echo [%timestamp%] CREATE PROCESS HASH DIRECTORY >> %_TimeStamp%

:: psloglist 
REM if psloglist64.exe occurs crash use 32bit psloglist.exe
%psloglist% -d 30 -s -t * /accepteula > %PROCESS_Dir%\psloglist.txt
REM %sysinternals%\psloglist.exe -d 30 -s -t * /accepteula > %PROCESS_Dir%\psloglist.txt
echo [%timestamp%] PSLOGLIST >> %_TimeStamp%


:: tasklist - ok 
tasklist -V > %PROCESS_Dir%\tasklist.txt
echo [%timestamp%] TASKLIST >> %_TimeStamp%

:: pslist 
%pslist% /accepteula > %PROCESS_Dir%\pslist.txt
echo [%timestamp%] PSLIST >> %_TimeStamp%

:: listdlls - ok
%Listdlls% /accepteula > %PROCESS_Dir%\listdll.txt 
echo [%timestamp%] LISTDLLS >> %_TimeStamp%

::handle - ok 
%handle% /accepteula > %PROCESS_Dir%\handle.txt
echo [%timestamp%] HANDLE >> %_TimeStamp%

:: tasklist /FO TABLE /NH > process_list.txt 
tasklist /FO TABLE /NH > %PROCESS_Dir%\tasklist.txt
echo [%timestamp%] TASKLIST >> %_TimeStamp%

:: regdllview64 /stext
%regdllview%\RegDllView.exe /stext %PROCESS_Dir%\regdllview.txt
echo [%timestamp%] REGDLLVIEW >> %_TimeStamp%

:: loadeddllsview /stext - ok 
%loadeddllsview%\LoadedDllsView.exe /stext %PROCESS_Dir%\loadeddllsview.txt
echo [%timestamp%] LOADEDDLLSVIEW >> %_TimeStamp%

:: driverview /stext - ok
%driverview%\DriverView.exe /stext %PROCESS_Dir%\driveview.txt
echo [%timestamp%] DRIVEVIEW >> %_TimeStamp%

:: cprocess - ok 
%nirsoft%\cprocess\CProcess.exe /stext %PROCESS_Dir%\cprocess.txt
echo [%timestamp%] CPROCESS >> %_TimeStamp%

:: openedfilesview /scomma
%ofview%\OpenedFilesView.exe /stext %PROCESS_Dir%\openedfilesview.txt
echo [%timestamp%] OPENEDFILESVIEW >> %_TimeStamp%

:: opensavefilesview
%opensavefilesview%\OpenSaveFilesView.exe /stext %PROCESS_Dir%\opensavefilesview.txt
echo [%timestamp%] OPENSAVEFILESVIEW >> %_TimeStamp%

:: executedprogramslist
%nirsoft%\executedprogramslist\ExecutedProgramsList.exe /stext %PROCESS_Dir%\executedprogramslist.txt
echo [%timestamp%] EXECUTEDPROGRAMSLIST >> %_TimeStamp%

:: installedpackagesview
%InstalledPackagesView%\InstalledPackagesView.exe /stext %PROCESS_Dir%\installedpackagesview.txt
echo [%timestamp%] INSTALLEDPACKAGESVIEW >> %_TimeStamp%

:: uninstallview
%UninstallView%\UninstallView.exe /stext %PROCESS_Dir%\uninstallview.txt
echo [%timestamp%] UNINSTALLVIEW >> %_TimeStamp%

:: mylastsearch
%nirsoft%\mylastsearch\MyLastSearch.exe /stext %PROCESS_Dir%\mylastsearch.txt
echo [%timestamp%] MYLASTSEARCH >> %_TimeStamp%

:: browsers 
%BrowserAddonsView%\BrowserAddonsView.exe /stext %PROCESS_Dir%\browseraddonsview.txt
echo [%timestamp%] BROWSERADDONSVIEW >> %_TimeStamp%

%BrowserDownloadsView%\BrowserDownloadsView.exe /stext %PROCESS_Dir%\browserdownloadsview.txt
echo [%timestamp%] BROWSERDOWNLOADSVIEW >> %_TimeStamp%

%BrowsingHistoryView%\BrowsingHistoryView.exe /stext %PROCESS_Dir%\browsinghistoryview.txt
echo [%timestamp%] BROWSINGHISTORYVIEW >> %_TimeStamp%

:: browser detection
set CHROME_COOKIES=%LocalAppData%\Google\Chrome\User Data\Default\Network\Cookies
set FIREFOX_PROFILE=%AppData%\Mozilla\Firefox\Profiles
set FIREFOX_COOKIES=cookies.sqlite
set EDGE_COOKIES=%LocalAppData%\Microsoft\Edge\User Data\Default\Network\Cookies
set IE_COOKIES=%AppData%\Microsoft\Windows\Cookies
set OPERA_COOKIES=%AppData%\Opera Software\Opera Stable\Network\Cookies

:: browser cookie
set CHROME_DESTINATION=%PROCESS_Dir%\Chrome_Cookies_Backup
set FIREFOX_DESTINATION=%PROCESS_Dir%\Firefox_Cookies_Backup
set EDGE_DESTINATION=%PROCESS_Dir%\Edge_Cookies_Backup
set IE_DESTINATION=%PROCESS_Dir%\IE_Cookies_Backup
set OPERA_DESTINATION=%PROCESS_Dir%\Opera_Cookies_Backup

if exist "%CHROME_COOKIES%" (
  xcopy /y /v "%CHROME_COOKIES%" "%CHROME_DESTINATION%\"
  echo [%timestamp%] CHROME COOKIE >> %_TimeStamp%
  echo Chrome cookies backed up.
  %hashdeep% "%CHROME_DESTINATION%\Cookies" > "%PROCESS_HASH%\Chrome_Cookies_hash.txt"
  echo [%timestamp%] Chrome Cookie HASH >> %_TimeStamp%
) else (
  echo Chrome cookies not found.
)

for /D %%i in ("%FIREFOX_PROFILE%\*") do (
  if exist "%%i\%FIREFOX_COOKIES%" (
    xcopy /y /v "%%i\%FIREFOX_COOKIES%" "%FIREFOX_DESTINATION%\"
    echo [%timestamp%] FIREFOX COOKIE >> %_TimeStamp%
    echo Firefox cookies backed up.
    %hashdeep% "%FIREFOX_DESTINATION%\cookies.sqlite" > "%PROCESS_HASH%\FIREFOX_Cookies_hash.txt"
    echo [%timestamp%] FIREFOX Cookie HASH >> %_TimeStamp%
  ) else (
    echo Firefox cookies not found.
  )
)

if exist "%EDGE_COOKIES%" (
  xcopy /y /v "%EDGE_COOKIES%" "%EDGE_DESTINATION%\"
  echo [%timestamp%] EDGE COOKIE >> %_TimeStamp%
  echo Edge cookies backed up.
  %hashdeep% "%EDGE_DESTINATION%\Cookies" > "%PROCESS_HASH%\EDGE_Cookies_hash.txt"
  echo [%timestamp%] EDGE Cookie HASH >> %_TimeStamp%
) else (
  echo Edge cookies not found.
)

if exist "%IE_COOKIES%" (
  xcopy /y /v /s "%IE_COOKIES%\*.*" "%IE_DESTINATION%\"
  echo [%timestamp%] IE COOKIE >> %_TimeStamp%
  echo Internet Explorer cookies backed up.
  %hashdeep% -r "%IE_DESTINATION%" > "%PROCESS_HASH%\IE_Cookies_hash.txt"
  echo [%timestamp%] IE Cookie HASH >> %_TimeStamp%
) else (
  echo Internet Explorer cookies not found.
)

if exist "%OPERA_COOKIES%" (
  xcopy /y /v "%OPERA_COOKIES%" "%OPERA_DESTINATION%\"
  echo [%timestamp%] OPERA COOKIE >> %_TimeStamp%
  echo Opera cookies backed up.
  %hashdeep% "%OPERA_DESTINATION%\Cookies" > "%PROCESS_HASH%\OPERA_Cookies_hash.txt"
  echo [%timestamp%] OPERA Cookie HASH >> %_TimeStamp%
) else (
  echo Opera cookies not found.
)

::echo Process Data collection is completed
::echo.
::echo Make Hash File


%hashdeep% "%PROCESS_Dir%\psloglist.txt" > "%PROCESS_HASH%\psloglist_hash.txt"
echo [%timestamp%] PSLOGLIST HASH >> %_TimeStamp%
%hashdeep% "%PROCESS_Dir%\tasklist.txt" > "%PROCESS_HASH%\tasklist_hash.txt"
echo [%timestamp%] TASKLIST HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\pslist.txt" > "%PROCESS_HASH%\pslist_hash.txt"
echo [%timestamp%] PSLIST HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\listdll.txt" > "%PROCESS_HASH%\listdll_hash.txt"
echo [%timestamp%] LISTDLL HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\handle.txt" > "%PROCESS_HASH%\handle_hash.txt"
echo [%timestamp%] HANDLE HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\regdllview.txt" > "%PROCESS_HASH%\regdllview_hash.txt"
echo [%timestamp%] REGDLLVIEW HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\loadeddllsview.txt" > "%PROCESS_HASH%\loadeddllsview_hash.txt"
echo [%timestamp%] LOADEDDLLSVIEW HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\driveview.txt" > "%PROCESS_HASH%\driveview_hash.txt"
echo [%timestamp%] DRIVEVIEW HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\cprocess.txt" > "%PROCESS_HASH%\cprocess_hash.txt"
echo [%timestamp%] CPROCESS HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\openedfilesview.txt" > "%PROCESS_HASH%\openedfilesview_hash.txt"
echo [%timestamp%] OPENEDFILESVIEW HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\opensavefilesview.txt" > "%PROCESS_HASH%\opensavefilesview_hash.txt"
echo [%timestamp%] OPENSAVEFILESVIEW HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\executedprogramslist.txt" > "%PROCESS_HASH%\executedprogramslist_hash.txt"
echo [%timestamp%] EXECUTEDPROGRAMSLIST HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\installedpackagesview.txt" > "%PROCESS_HASH%\installedpackagesview_hash.txt"
echo [%timestamp%] INSTALLEDPACKAGESVIEW HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\uninstallview.txt" > "%PROCESS_HASH%\uninstallview_hash.txt"
echo [%timestamp%] UNINSTALLVIEW HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\mylastsearch.txt" > "%PROCESS_HASH%\mylastsearch_hash.txt"
echo [%timestamp%] MYLASTSEARCH HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\browseraddonsview.txt" > "%PROCESS_HASH%\browseraddonsview_hash.txt"
echo [%timestamp%] BROWSERADDONSVIEW HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\browserdownloadsview.txt" > "%PROCESS_HASH%\browserdownloadsview_hash.txt"
echo [%timestamp%] BROWSERDOWNLOADSVIEW HASH >> %_TimeStamp%

%hashdeep% "%PROCESS_Dir%\browsinghistoryview.txt" > "%PROCESS_HASH%\browsinghistoryview_hash.txt"
echo [%timestamp%] BROWSINGHISTORYVIEW HASH >> %_TimeStamp%

echo PROCESS INFORMATION CLEAR
echo [%timestamp%] PROCESS INFORMATION CLEAR >> %_TimeStamp%

echo Step completed: %choice%

exit /b

:run_step_4
call :LogStep
echo -----------------------------
echo 4. LOGON USER INFORMATION
echo [%timestamp%] LOGON USER INFORMATION START >> %_TimeStamp%
echo -----------------------------
echo.

set Logon_Dir=%volatile_dir%\Logon_Information
mkdir %Logon_Dir%
echo [%timestamp%] CREATE LOGON DIRECTORY >> %_TimeStamp%
echo --------------------------
echo CREATE LOGON DIRECTORY
echo.
echo ACQUIRING INFORMATION
echo --------------------------

:: psloggedon - ok 
%PsLoggedon% /accepteula > %Logon_Dir%\psloggedon.txt 
echo [%timestamp%] PSLOGGEDON >> %_TimeStamp%

:: logonsessions /accepteula - ok
%logonsessions% /accepteula > %Logon_Dir%\logonsessions.txt 
echo [%timestamp%] LOGONSESSIONS >> %_TimeStamp%

:: net user - ok 
net user > %Logon_Dir%\net_user.txt
echo [%timestamp%] NET USER >> %_TimeStamp%

:: winlogonview - ok
%nirsoft%\winlogonview\WinLogOnView.exe /scomma %Logon_Dir%\winlogonview.txt
echo [%timestamp%] WINLOGONVIEW >> %_TimeStamp%

::echo Logon Data collection is complete.
::echo.
::echo Make Hash File

set LOGON_HASH=%Logon_Dir%\HASH
mkdir %LOGON_HASH%
echo [%timestamp%] CREATE LOGON HASH DIRECTORY >> %_TimeStamp%

%hashdeep% "%Logon_Dir%\psloggedon.txt" > "%LOGON_HASH%\psloggedon_hash.txt"
echo [%timestamp%] PSLOGGEDON HASH >> %_TimeStamp%

%hashdeep% "%Logon_Dir%\logonsessions.txt" > "%LOGON_HASH%\logonsessions_hash.txt"
echo [%timestamp%] LOGONSESSIONS HASH >> %_TimeStamp%

%hashdeep% "%Logon_Dir%\net_user.txt" > "%LOGON_HASH%\net_user_hash.txt"
echo [%timestamp%] NET USER HASH >> %_TimeStamp%

%hashdeep% "%Logon_Dir%\winlogonview.txt" > "%LOGON_HASH%\winlogonview_hash.txt"
echo [%timestamp%] WINLOGONVIEW HASH >> %_TimeStamp%

echo LOGON INFORMATION CLEAR
echo [%timestamp%] LOGON INFORMATION CLEAR >> %_TimeStamp%

echo Step completed: %choice%
exit /b

:run_step_5
call :LogStep
echo -----------------------------
echo 5. SYSTEM INFORMATION
echo [%timestamp%] SYSTEM INFORMATION START >> %_TimeStamp%
echo -----------------------------
echo.

set SYSTEM_INFO_Dir=%volatile_dir%\System_Information
mkdir %SYSTEM_INFO_Dir%
echo [%timestamp%] CREATE SYTEM Information Directory >> %_TimeStamp%

:: echo Make Hash File
set SYSTEM_INFO_HASH=%SYSTEM_INFO_Dir%\HASH
echo [%timestamp%]REGISTRY HASH DIRECTORY CREATE >> %_TimeStamp%
mkdir %SYSTEM_INFO_HASH%
echo ------------------------------------------
echo CREATE SYTEM Information Directory
echo.
echo ACQUIRING INFORMATION
echo ------------------------------------------
REM Collect system information
systeminfo > "%SYSTEM_INFO_Dir%\systeminfo.txt"
echo.
echo.
echo.
echo Start the necessary services required for executing subsequent commands
echo.
net start "Windows Event Collector"
net start "Windows Event Log"
net start "Windows Management Instrumentation"

echo Now, we will collect information from Windows Event Log
REM Check if "Windows Event Log" service is running
sc query eventlog | findstr "RUNNING" >nul
if %ERRORLEVEL% EQU 0 (
    REM Service is running, extract system information
    echo Extracting system information...
    echo.

    REM Start "Windows Event Log" service if it's not running
) else (
    echo Warning: Windows Event Log service is not running. Attempting to start the service...
    net start eventlog > nul 2>&1 || (
        echo Failed to start the "Windows Event Log" service.
        echo Please start the service to extract system information.
        goto :Display_Menu
    )
)
echo.

REM Collect system log
wevtutil epl System "%SYSTEM_INFO_Dir%\system_log.evtx" 
echo [%timestamp%] wevtutil system log >> %_TimeStamp%

REM Collect security log
wevtutil epl Security "%SYSTEM_INFO_Dir%\security_log.evtx"
echo [%timestamp%] wevtutil security log >> %_TimeStamp%

REM Collect application log
wevtutil epl Application "%SYSTEM_INFO_Dir%\application_log.evtx"
echo [%timestamp%] wevtutil application log >> %_TimeStamp%

echo Collecting important registry information

REM Collect registry information
reg save HKEY_LOCAL_MACHINE\SAM "%SYSTEM_INFO_Dir%\SAM.hiv" && echo SAM registry file dumped to : "%SYSTEM_INFO_Dir%"
echo [%timestamp%] REG SAVE SAM >> %_TimeStamp%
reg save HKEY_LOCAL_MACHINE\SOFTWARE "%SYSTEM_INFO_Dir%\HKLM-Software.hiv" && echo SOFTWARE registry file dumped to : "%SYSTEM_INFO_Dir%"
echo [%timestamp%] REG SAVE SOFTWARE >> %_TimeStamp%
reg save HKEY_LOCAL_MACHINE\SYSTEM "%SYSTEM_INFO_Dir%\SYSTEM.hiv" && echo SYSTEM registry file dumped to : "%SYSTEM_INFO_Dir%"
echo [%timestamp%] REG SAVE SYSTEM >> %_TimeStamp%
reg save HKEY_LOCAL_MACHINE\SECURITY "%SYSTEM_INFO_Dir%\SECURITY.hiv" &&  echo SECURITY registry file dumped to : "%SYSTEM_INFO_Dir%"
echo [%timestamp%] REG SAVE SECURITY >> %_TimeStamp%
echo Starting HKEY_USERS Batch Script...
call .\HKEY_USERS.bat

REM BLUESCREENVIEW
echo ACQUIRING BLUESCREEN INFORMATION
%bluescreenview%\BlueScreenView.exe /stext %SYSTEM_INFO_Dir%\bluescreenview.txt
echo [%timestamp%]ACQUIRING BLUESCREEN INFORMATION >> %_TimeStamp%

:: --------------------
:: system log hash
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\system_log.evtx" > "%SYSTEM_INFO_HASH%\system_log_event.txt"
echo [%timestamp%] wevtutil system HASH >> %_TimeStamp%

:: --------------------
:: security log hash
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\security_log.evtx" > "%SYSTEM_INFO_HASH%\security_log_event.txt"
echo [%timestamp%] wevtutil security HASH >> %_TimeStamp%

:: --------------------
:: application log hash
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\application_log.evtx" > "%SYSTEM_INFO_HASH%\application_log_event.txt"
echo [%timestamp%] wevtutil application HASH >> %_TimeStamp%

:: --------------------
:: SAM FILE HASH
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\SAM.hiv" > "%SYSTEM_INFO_HASH%\SAM_HASH.txt"
echo [%timestamp%] SAM HASH >> %_TimeStamp%

:: --------------------
:: SOFTWARE FILE HASH
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\SOFTWARE.hiv" > "%SYSTEM_INFO_HASH%\SOFTWARE_HASH.txt"
echo [%timestamp%] SOFTWARE HASH >> %_TimeStamp%

:: --------------------
:: SYSTEM FILE HASH
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\SYSTEM.hiv" > "%SYSTEM_INFO_HASH%\SYSTEM_HASH.txt"
echo [%timestamp%] SYSTEM HASH >> %_TimeStamp%

:: --------------------
:: SECURITY FILE HASH
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\SECURITY.hiv" > "%SYSTEM_INFO_HASH%\SECURITY_HASH.txt"
echo [%timestamp%] SECURITY HASH >> %_TimeStamp%

:: --------------------
:: BLUESCREENVIEW_HASH
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\bluescreenview.txt" > "%SYSTEM_INFO_HASH%\BLUESCREENVIEW_HASH.txt"
echo [%timestamp%] BLUESCREENVIEW HASH >> %_TimeStamp%

echo SYSTEM INFORMATION CLEAR 
echo [%timestamp%] SYSTEM INFORMATION CLEAR >> %_TimeStamp%
echo.

echo Step completed: %choice%
exit /b

:run_step_6
call :LogStep
echo -----------------------------
echo 6. AUTORUNS
echo [%timestamp%] AUTORUNS START >> %_TimeStamp%
echo -----------------------------
echo.

set Autoruns_Dir=%volatile_dir%\Autoruns_Information
mkdir %Autoruns_Dir%
echo [%timestamp%] CREATE Autoruns DIRECTORY >> %_TimeStamp%
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
%autorunsc% /accepteula -a * -c -ct csv -nobanner > "%SYSTEM_INFO_Dir%\AutoRuns.csv"

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
call :LogStep
echo -----------------------------------------------
echo 7. TASK SCHEDULAR and CLIPBOARD(TSCB)
echo [%timestamp%] "TASK SCHEDULAR and CLIPBOARD START" >> %_TimeStamp%
echo -----------------------------------------------
echo.

set TSCB_Dir=%volatile_dir%\TSCB_Information
mkdir %TSCB_Dir%
echo [%timestamp%] CREATE TSCB DIRECTORY >> %_TimeStamp%
echo -------------------------------
echo CREATE TSCB DIRECTORY
echo.
echo ACQUIRING INFORMATION
echo -------------------------------
REM Collect clipboard information
%etc%\pclip.exe > "%TSCB_Dir%\clipboard.txt"
REM Collect scheduled tasks information using schtasks
echo Collecting scheduled tasks information...
schtasks /query /fo CSV /v > "%TSCB_Dir%\ScheduledTasks.csv"
echo Scheduled tasks information collected successfully.
echo.
echo Step completed: %choice%
exit /b

:LogStep
echo ========================== >> %_TimeStamp%
goto :eof

:end_script
echo SCRIPT FINISHED
endlocal
exit 