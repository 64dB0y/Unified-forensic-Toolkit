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
set PHYSICAL_MEMORY_HASH=%Memory_Dump_dir%\HASH
mkdir %PHYSICAL_MEMORY_HASH%
echo [%timestamp%] CREATE PHYSICAL MEMORY HASH DIRECTORY >> %TimeStamp%
echo.
echo Dumping RAM...
:choose_ram_dump_tool
set /p "ram_dump_tool=Which RAM dump tool to use? (R=RamCapture, W=Winpmem, C=CyLR, Q=quit): "
echo.
echo.
:: To Hash RamCapture result file
set current_date=%date:~0,4%%date:~5,2%%date:~8,2%

if /I "%ram_dump_tool%"=="R" (
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
    
    echo [%timestamp%] RamCapture Finished >> %TimeStamp%
    echo Please wait, this may take some time - Calculating the hash values for the recently created dump file
    %hashdeep% "%Memory_Dump_dir%\%current_date%.mem" > "%PHYSICAL_MEMORY_HASH%\RamCapture_hash.txt"
    echo [%timestamp%] RamCapture HASH >> %TimeStamp%
    timeout /t 10
    goto choose_ram_dump_tool
) else if /I "%ram_dump_tool%"=="W" (
    set /p "user_id=Please input the user ID of someone with administrator privileges: "
    set /p "user_pw=Please input the password for the user with administrator privileges (leave empty if none): "
    if not defined user_pw (
        "%psexec%" -u %user_id% -accepteula -i -s cmd.exe /c "call %Winpmem% %Memory_Dump_dir%\physmem.raw"
    ) else (
        "%psexec%" -u %user_id% -p %user_pw% -accepteula -i -s cmd.exe /c "call %Winpmem% %Memory_Dump_dir%\physmem.raw"
    )
    echo [%timestamp%] Winpmem Finished >> %TimeStamp%
    %hashdeep% "%Memory_Dump_dir%\physmem.raw" > "%PHYSICAL_MEMORY_HASH%\physmem_hash.txt"
    echo [%timestamp%] Winpmem HASH >> %TimeStamp%
    timeout /t 10
    goto choose_ram_dump_tool
) else if /I "%ram_dump_tool%"=="C" (
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
    "%psexec%" -accepteula -i -s cmd.exe /c "call %CyLR% -od %Memory_Dump_dir% -of memory_dump.zip -zp !result_password! -zl 9"
    echo [%timestamp%] CyLR Finished >> %TimeStamp%
    %hashdeep% "%Memory_Dump_dir%\memory_dump.zip" > "%PHYSICAL_MEMORY_HASH%\memory_dump_hash.txt"
    echo [%timestamp%] CyLR HASH >> %TimeStamp%
    timeout /t 10
    goto choose_ram_dump_tool
) else if /i "%ram_dump_tool%"=="Q" (
    echo You chose to quit: Q
    echo There's no other option to dump Memory
) else (
    echo Invalid choice, please try again
    goto choose_ram_dump_tool
)
echo [%timestamp%] Memory Dump Finished >> %TimeStamp%

exit /b

:run_step_1
:: 1. Virtual Memory Dump
echo -----------------------------
echo 1. Dumping Virtual memory...
echo [%timestamp%] Virtual memory START >> %TimeStamp%
echo -----------------------------
echo.

set Virtual_Memory_dir=%volatile_dir%\Virtual_Memory
mkdir %Virtual_Memory_dir%
echo --------------------------
echo CREATE Virtual_Memory DIRECTORY
echo [%timestamp%] CREATE Virtual_Memory DIRECTORY >> %TimeStamp%
echo ACQUIRING INFORMATION
echo --------------------------
echo.
echo.
echo [%timestamp%] Dumping Virtual Memory >> %TimeStamp%

:: To get the session ID
for /f "tokens=4" %%i in ('tasklist /nh /fi "imagename eq cmd.exe" /fi "sessionname eq console"') do set sessionId=%%i

"%psexec%" -accepteula -i %sessionId% -s cmd.exe /c "call %dump%\1_Virtual_Memory_dump.bat %sysinternals% %Virtual_Memory_dir% %TimeStamp% %hash%"
echo.
echo [%timestamp%] Virtual Memory Dump Completed >> %TimeStamp%
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

%cports%\cports.exe /stext "%Network_dir%\cports.txt"
echo [%timestamp%] cports >> %TimeStamp%

%tcplogview%\tcplogview.exe /stext "%Network_dir%\tcplogview.txt"
echo [%timestamp%] tcplogview >> %TimeStamp%

%wifiinfoview%\WifiInfoView.exe /stext "%Network_dir%\wifiInfoView.txt
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
%hashdeep% "%Network_dir%\arp.txt" > "%NETWORK_HASH%\arp_hash.txt"
echo [%timestamp%] ARP HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\route.txt" > "%NETWORK_HASH%\route_hash.txt"
echo [%timestamp%] ROUTE HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\netstat.txt" > "%NETWORK_HASH%\netstat_hash.txt"
echo [%timestamp%] NETSTAT HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\net_sessions.txt" > "%NETWORK_HASH%\net_sessions_hash.txt"
echo [%timestamp%] NETSESSION HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\net_file.txt" > "%NETWORK_HASH%\net_file_hash.txt"
echo [%timestamp%] NET FILE HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\net_share.txt" > "%NETWORK_HASH%\net_share_hash.txt"
echo [%timestamp%] NET SHARE HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\arp.txt" > "%NETWORK_HASH%\arp_hash.txt"
echo [%timestamp%] ARP HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\nbtstat_c.txt" > "%NETWORK_HASH%\nbtstat_c_hash.txt"
echo [%timestamp%] NBTSTAT_C HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\nbtstat_s.txt" > "%NETWORK_HASH%\nbtstat_s_hash.txt"
echo [%timestamp%] NBTSTAT_S HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\ipconfig.txt" > "%NETWORK_HASH%\ipconfig_hash.txt"
echo [%timestamp%] IPCONFIG HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\urlprotocolview.txt" > "%NETWORK_HASH%\urlprotocolview_hash.txt"
echo [%timestamp%] URLPROTOCOLVIEW HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\cports.txt" > "%NETWORK_HASH%\cports_hash.txt"
echo [%timestamp%] CPORTS HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\tcplogview.txt" > "%NETWORK_HASH%\tcplogview_hash.txt"
echo [%timestamp%] TCPLOGVIEW HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\wifiInfoView.txt" > "%NETWORK_HASH%\wifiInfoView_hash.txt"
echo [%timestamp%] WIFIINFOVIEW HASH >> %TimeStamp%

%hashdeep% "%Network_dir%\WirelessNetView.txt" > "%NETWORK_HASH%\WirelessNetView_hash.txt"
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

set PROCESS_HASH=%PROCESS_Dir%\HASH
mkdir %PROCESS_HASH%
echo [%timestamp%] CREATE PROCESS HASH DIRECTORY >> %TimeStamp%

:: psloglist 
%psloglist% -d 30 -s -t * /accepteula > %PROCESS_Dir%\psloglist.txt
echo [%timestamp%] PSLOGLIST >> %TimeStamp%


:: tasklist - ok 
tasklist -V > %PROCESS_Dir%\tasklist.txt
echo [%timestamp%] TASKLIST >> %TimeStamp%

:: pslist 
%pslist% /accepteula > %PROCESS_Dir%\pslist.txt
echo [%timestamp%] PSLIST >> %TimeStamp%

:: listdlls - ok
%Listdlls% /accepteula > %PROCESS_Dir%\listdll.txt 
echo [%timestamp%] LISTDLLS >> %TimeStamp%

::handle - ok 
%handle% /accepteula > %PROCESS_Dir%\handle.txt
echo [%timestamp%] HANDLE >> %TimeStamp%

:: tasklist /FO TABLE /NH > process_list.txt 
tasklist /FO TABLE /NH > %PROCESS_Dir%\tasklist.txt
echo [%timestamp%] TASKLIST >> %TimeStamp%

:: regdllview64 /stext
%regdllview%\RegDllView.exe /stext %PROCESS_Dir%\regdllview.txt
echo [%timestamp%] REGDLLVIEW >> %TimeStamp%

:: loadeddllsview /stext - ok 
%loadeddllsview%\LoadedDllsView.exe /stext %PROCESS_Dir%\loadeddllsview.txt
echo [%timestamp%] LOADEDDLLSVIEW >> %TimeStamp%

:: driverview /stext - ok
%driverview%\DriverView.exe /stext %PROCESS_Dir%\driveview.txt
echo [%timestamp%] DRIVEVIEW >> %TimeStamp%

:: cprocess - ok 
%nirsoft%\cprocess\CProcess.exe /stext %PROCESS_Dir%\cprocess.txt
echo [%timestamp%] CPROCESS >> %TimeStamp%

:: openedfilesview /scomma
%ofview%\OpenedFilesView.exe /stext %PROCESS_Dir%\openedfilesview.txt
echo [%timestamp%] OPENEDFILESVIEW >> %TimeStamp%

:: opensavefilesview
%opensavefilesview%\OpenSaveFilesView.exe /stext %PROCESS_Dir%\opensavefilesview.txt
echo [%timestamp%] OPENSAVEFILESVIEW >> %TimeStamp%

:: executedprogramslist
%nirsoft%\executedprogramslist\ExecutedProgramsList.exe /stext %PROCESS_Dir%\executedprogramslist.txt
echo [%timestamp%] EXECUTEDPROGRAMSLIST >> %TimeStamp%

:: installedpackagesview
%InstalledPackagesView%\InstalledPackagesView.exe /stext %PROCESS_Dir%\installedpackagesview.txt
echo [%timestamp%] INSTALLEDPACKAGESVIEW >> %TimeStamp%

:: uninstallview
%UninstallView%\UninstallView.exe /stext %PROCESS_Dir%\uninstallview.txt
echo [%timestamp%] UNINSTALLVIEW >> %TimeStamp%

:: mylastsearch
%nirsoft%\mylastsearch\MyLastSearch.exe /stext %PROCESS_Dir%\mylastsearch.txt
echo [%timestamp%] MYLASTSEARCH >> %TimeStamp%

:: browsers 
%BrowserAddonsView%\BrowserAddonsView.exe /stext %PROCESS_Dir%\browseraddonsview.txt
echo [%timestamp%] BROWSERADDONSVIEW >> %TimeStamp%

%BrowserDownloadsView%\BrowserDownloadsView.exe /stext %PROCESS_Dir%\browserdownloadsview.txt
echo [%timestamp%] BROWSERDOWNLOADSVIEW >> %TimeStamp%

%BrowsingHistoryView%\BrowsingHistoryView.exe /stext %PROCESS_Dir%\browsinghistoryview.txt
echo [%timestamp%] BROWSINGHISTORYVIEW >> %TimeStamp%

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
  echo [%timestamp%] CHROME COOKIE >> %TimeStamp%
  echo Chrome cookies backed up.
  %hashdeep% "%CHROME_DESTINATION%\Cookies" > "%PROCESS_HASH%\Chrome_Cookies_hash.txt"
  echo [%timestamp%] Chrome Cookie HASH >> %TimeStamp%
) else (
  echo Chrome cookies not found.
)

for /D %%i in ("%FIREFOX_PROFILE%\*") do (
  if exist "%%i\%FIREFOX_COOKIES%" (
    xcopy /y /v "%%i\%FIREFOX_COOKIES%" "%FIREFOX_DESTINATION%\"
    echo [%timestamp%] FIREFOX COOKIE >> %TimeStamp%
    echo Firefox cookies backed up.
    %hashdeep% "%FIREFOX_DESTINATION%\cookies.sqlite" > "%PROCESS_HASH%\FIREFOX_Cookies_hash.txt"
    echo [%timestamp%] FIREFOX Cookie HASH >> %TimeStamp%
  ) else (
    echo Firefox cookies not found.
  )
)

if exist "%EDGE_COOKIES%" (
  xcopy /y /v "%EDGE_COOKIES%" "%EDGE_DESTINATION%\"
  echo [%timestamp%] EDGE COOKIE >> %TimeStamp%
  echo Edge cookies backed up.
  %hashdeep% "%EDGE_DESTINATION%\Cookies" > "%PROCESS_HASH%\EDGE_Cookies_hash.txt"
  echo [%timestamp%] EDGE Cookie HASH >> %TimeStamp%
) else (
  echo Edge cookies not found.
)

if exist "%IE_COOKIES%" (
  xcopy /y /v /s "%IE_COOKIES%\*.*" "%IE_DESTINATION%\"
  echo [%timestamp%] IE COOKIE >> %TimeStamp%
  echo Internet Explorer cookies backed up.
  %hashdeep% -r "%IE_DESTINATION%" > "%PROCESS_HASH%\IE_Cookies_hash.txt"
  echo [%timestamp%] IE Cookie HASH >> %TimeStamp%
) else (
  echo Internet Explorer cookies not found.
)

if exist "%OPERA_COOKIES%" (
  xcopy /y /v "%OPERA_COOKIES%" "%OPERA_DESTINATION%\"
  echo [%timestamp%] OPERA COOKIE >> %TimeStamp%
  echo Opera cookies backed up.
  %hashdeep% "%OPERA_DESTINATION%\Cookies" > "%PROCESS_HASH%\OPERA_Cookies_hash.txt"
  echo [%timestamp%] OPERA Cookie HASH >> %TimeStamp%
) else (
  echo Opera cookies not found.
)

::echo Process Data collection is completed
::echo.
::echo Make Hash File


%hashdeep% "%PROCESS_Dir%\psloglist.txt" > "%PROCESS_HASH%\psloglist_hash.txt"
echo [%timestamp%] PSLOGLIST HASH >> %TimeStamp%
%hashdeep% "%PROCESS_Dir%\tasklist.txt" > "%PROCESS_HASH%\tasklist_hash.txt"
echo [%timestamp%] TASKLIST HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\pslist.txt" > "%PROCESS_HASH%\pslist_hash.txt"
echo [%timestamp%] PSLIST HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\listdll.txt" > "%PROCESS_HASH%\listdll_hash.txt"
echo [%timestamp%] LISTDLL HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\handle.txt" > "%PROCESS_HASH%\handle_hash.txt"
echo [%timestamp%] HANDLE HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\regdllview.txt" > "%PROCESS_HASH%\regdllview_hash.txt"
echo [%timestamp%] REGDLLVIEW HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\loadeddllsview.txt" > "%PROCESS_HASH%\loadeddllsview_hash.txt"
echo [%timestamp%] LOADEDDLLSVIEW HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\driveview.txt" > "%PROCESS_HASH%\driveview_hash.txt"
echo [%timestamp%] DRIVEVIEW HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\cprocess.txt" > "%PROCESS_HASH%\cprocess_hash.txt"
echo [%timestamp%] CPROCESS HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\openedfilesview.txt" > "%PROCESS_HASH%\openedfilesview_hash.txt"
echo [%timestamp%] OPENEDFILESVIEW HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\opensavefilesview.txt" > "%PROCESS_HASH%\opensavefilesview_hash.txt"
echo [%timestamp%] OPENSAVEFILESVIEW HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\executedprogramslist.txt" > "%PROCESS_HASH%\executedprogramslist_hash.txt"
echo [%timestamp%] EXECUTEDPROGRAMSLIST HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\installedpackagesview.txt" > "%PROCESS_HASH%\installedpackagesview_hash.txt"
echo [%timestamp%] INSTALLEDPACKAGESVIEW HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\uninstallview.txt" > "%PROCESS_HASH%\uninstallview_hash.txt"
echo [%timestamp%] UNINSTALLVIEW HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\mylastsearch.txt" > "%PROCESS_HASH%\mylastsearch_hash.txt"
echo [%timestamp%] MYLASTSEARCH HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\browseraddonsview.txt" > "%PROCESS_HASH%\browseraddonsview_hash.txt"
echo [%timestamp%] BROWSERADDONSVIEW HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\browserdownloadsview.txt" > "%PROCESS_HASH%\browserdownloadsview_hash.txt"
echo [%timestamp%] BROWSERDOWNLOADSVIEW HASH >> %TimeStamp%

%hashdeep% "%PROCESS_Dir%\browsinghistoryview.txt" > "%PROCESS_HASH%\browsinghistoryview_hash.txt"
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
%PsLoggedon% /accepteula > %Logon_Dir%\psloggedon.txt 
echo [%timestamp%] PSLOGGEDON >> %TimeStamp%

:: logonsessions /accepteula - ok
%logonsessions% /accepteula > %Logon_Dir%\logonsessions.txt 
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

%hashdeep% "%Logon_Dir%\psloggedon.txt" > "%LOGON_HASH%\psloggedon_hash.txt"
echo [%timestamp%] PSLOGGEDON HASH >> %TimeStamp%

%hashdeep% "%Logon_Dir%\logonsessions.txt" > "%LOGON_HASH%\logonsessions_hash.txt"
echo [%timestamp%] LOGONSESSIONS HASH >> %TimeStamp%

%hashdeep% "%Logon_Dir%\net_user.txt" > "%LOGON_HASH%\net_user_hash.txt"
echo [%timestamp%] NET USER HASH >> %TimeStamp%

%hashdeep% "%Logon_Dir%\winlogonview.txt" > "%LOGON_HASH%\winlogonview_hash.txt"
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

set SYSTEM_INFO_Dir=%volatile_dir%\System_Information
mkdir %SYSTEM_INFO_Dir%
echo [%timestamp%] CREATE SYTEM Information Directory >> %TimeStamp%

:: echo Make Hash File
set SYSTEM_INFO_HASH=%SYSTEM_INFO_Dir%\HASH
echo [%timestamp%]REGISTRY HASH DIRECTORY CREATE >> %TimeStamp%
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
echo [%timestamp%] wevtutil system log >> %TimeStamp%

REM Collect security log
wevtutil epl Security "%SYSTEM_INFO_Dir%\security_log.evtx"
echo [%timestamp%] wevtutil security log >> %TimeStamp%

REM Collect application log
wevtutil epl Application "%SYSTEM_INFO_Dir%\application_log.evtx"
echo [%timestamp%] wevtutil application log >> %TimeStamp%

echo Collecting important registry information

REM Collect registry information
reg save HKEY_LOCAL_MACHINE\SAM "%SYSTEM_INFO_Dir%\SAM.hiv" && echo SAM registry file dumped to : "%SYSTEM_INFO_Dir%"
echo [%timestamp%] REG SAVE SAM >> %TimeStamp%
reg save HKEY_LOCAL_MACHINE\SOFTWARE "%SYSTEM_INFO_Dir%\HKLM-Software.hiv" && echo SOFTWARE registry file dumped to : "%SYSTEM_INFO_Dir%"
echo [%timestamp%] REG SAVE SOFTWARE >> %TimeStamp%
reg save HKEY_LOCAL_MACHINE\SYSTEM "%SYSTEM_INFO_Dir%\SYSTEM.hiv" && echo SYSTEM registry file dumped to : "%SYSTEM_INFO_Dir%"
echo [%timestamp%] REG SAVE SYSTEM >> %TimeStamp%
reg save HKEY_LOCAL_MACHINE\SECURITY "%SYSTEM_INFO_Dir%\SECURITY.hiv" &&  echo SECURITY registry file dumped to : "%SYSTEM_INFO_Dir%"
echo [%timestamp%] REG SAVE SECURITY >> %TimeStamp%
echo Starting HKEY_USERS Batch Script...
call .\HKEY_USERS.bat

REM BLUESCREENVIEW
echo ACQUIRING BLUESCREEN INFORMATION
%bluescreenview%\BlueScreenView.exe /stext %SYSTEM_INFO_Dir%\bluescreenview.txt
echo [%timestamp%]ACQUIRING BLUESCREEN INFORMATION >> %TimeStamp%

:: --------------------
:: system log hash
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\system_log.evtx" > "%SYSTEM_INFO_HASH%\system_log_event.txt"
echo [%timestamp%] wevtutil system HASH >> %TimeStamp%

:: --------------------
:: security log hash
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\security_log.evtx" > "%SYSTEM_INFO_HASH%\security_log_event.txt"
echo [%timestamp%] wevtutil security HASH >> %TimeStamp%

:: --------------------
:: application log hash
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\application_log.evtx" > "%SYSTEM_INFO_HASH%\application_log_event.txt"
echo [%timestamp%] wevtutil application HASH >> %TimeStamp%

:: --------------------
:: SAM FILE HASH
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\SAM.hiv" > "%SYSTEM_INFO_HASH%\SAM_HASH.txt"
echo [%timestamp%] SAM HASH >> %TimeStamp%

:: --------------------
:: SOFTWARE FILE HASH
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\SOFTWARE.hiv" > "%SYSTEM_INFO_HASH%\SOFTWARE_HASH.txt"
echo [%timestamp%] SOFTWARE HASH >> %TimeStamp%

:: --------------------
:: SYSTEM FILE HASH
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\SYSTEM.hiv" > "%SYSTEM_INFO_HASH%\SYSTEM_HASH.txt"
echo [%timestamp%] SYSTEM HASH >> %TimeStamp%

:: --------------------
:: SECURITY FILE HASH
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\SECURITY.hiv" > "%SYSTEM_INFO_HASH%\SECURITY_HASH.txt"
echo [%timestamp%] SECURITY HASH >> %TimeStamp%

:: --------------------
:: BLUESCREENVIEW_HASH
:: --------------------
%hashdeep% "%SYSTEM_INFO_Dir%\bluescreenview.txt" > "%SYSTEM_INFO_HASH%\BLUESCREENVIEW_HASH.txt"
echo [%timestamp%] BLUESCREENVIEW HASH >> %TimeStamp%

echo SYSTEM INFORMATION CLEAR 
echo [%timestamp%] SYSTEM INFORMATION CLEAR >> %TimeStamp%
echo.

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