@echo off
setlocal enabledelayedexpansion

:: PATH Settings 사용 도구 dd, forecopy_handy(v1.2)

SET "curDir=%~dp0"
SET "ETC=%~dp0etc"
set "sysinternals=%~dp0sysinternalsSuite"
SET "HASH=%~dp0HASH"
set "dump=%~dp0Memory_Dump_Tool"
set "kape=%~dp0kape"
SET "PATH=%curDir%;%ETC%;%sysinternals%;%HASH%;%dump%;%kape%;%PATH%"

set CASE=%1
set NAME=%2
set "_System_Drive=%systemdrive%"
set "_FirstCharacter=%_System_Drive:~0,1%"
:: SET DATE AND TIME
set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%
set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
set minute=%time:~3,2%
set second=%time:~6,2%

:: TIMESTAMP SET 
set timestamp=%year%-%month%-%day%_%hour%-%minute%-%second%

:: FOLDER SET
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
echo CREATE %foldername% DIRECTORY 

:: LOG TIMESTAMP
set _TimeStamp=%foldername%\TimeStamp.log
::echo START TIME : %timestamp%
echo [%timestamp%] START TIME >> %_TimeStamp%

:: CREATE NONVOLATILE DATA DIRECTORY
set NONVOLATILE_DIR=%foldername%\NONVOLATILE
mkdir %NONVOLATILE_DIR%
echo [%timestamp%] CREATE NONVOLATILE DIRECTORY >> %_TimeStamp%

:: INPUT CASE, NAME
:INPUT_CASE
    echo [%timestamp%]%CASE% >> %_TimeStamp%

:INPUT_NAME
    echo [%timestamp%]%NAME% >> %_TimeStamp%

:START
echo %CASE% - %NAME% Inactive Data Collection Begins >> %_TimeStamp%
echo .

:: Check .NET Framework4 or 6
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" >nul 2>&1
if %errorlevel%==0 (
    echo .NET Framework version 4 is installed. >>%NONVOLATILE_DIR%\basic_info.txt
    set "net=4"
    set "mftecmd=%curDir%\net4\MFTECmd\MFTECmd.exe"
    set "rbcmd=%curDir%\net4\RBCMD\RBCmd.exe"
    set "lecmd=%curDir%\net4\LECmd\LECmd.exe"
    set "jlecmd=%curDir%\net4\JLECmd\JLECmd.exe"
    set "pecmd=%curDir%\net4\PECmd\PECmd.exe"
    set "evtxecmd=%curDir%\net4\EvtxeCmd\EvtxECmd.exe"
    goto Check_Architecture
)

reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v6.0" >nul 2>&1
if %errorlevel%==0 (
    echo .NET Framework version 6 is installed. >> %NONVOLATILE_DIR%\basic_info.txt
    set "net=6"
    set "mftecmd=%curDir%\net6\MFTECmd\MFTECmd.exe"
    set "rbcmd=%curDir%\net6\RBCmd\RBCmd.exe"
    set "lecmd=%curDir%\net6\LECmd\LECmd.exe"
    set "jlecmd=%curDir%\net6\JLECmd\JLECmd.exe"
    set "pecmd=%curDir%\net6\PECmd\PECmd.exe"
    set "evtxecmd=%curDir%\net6\EvtxeCmd\EvtxECmd.exe"
    goto Check_Architecture
)

echo .NET Framework is not installed. >> %NONVOLATILE_DIR%\basic_info.txt
goto Check_Architecture

:Check_Architecture
    :: -----------------Architecture Detection-----------------
    if %PROCESSOR_ARCHITECTURE%==AMD64 (
        echo 64-bit operating system detected. >> %NONVOLATILE_DIR%\basic_info.txt
        set "psexec=%sysinternals%\PsExec64.exe"
        set "CyLR=%dump%\CyLR\CyLR_64.exe"
        set "hashdeep=%HASH%\hashdeep64.exe"

    ) else if %PROCESSOR_ARCHITECTURE%==x86 (
        echo 32-bit operating system detected. >> %NONVOLATILE_DIR%\basic_info.txt
        set "psexec=%sysinternals%\PsExec.exe"
        set "CyLR=%dump%\CyLR\CyLR_32.exe"
        set "hashdeep=%HASH%\hashdeep.exe"
    ) else (
        echo Unknown archtecture detected. >> %NONVOLATILE_DIR%\basic_info.txt
    )

echo **********************************
echo.
echo NONVOLATILE DATA
echo.
echo **********************************
echo.
echo.

set final_step=9
set choice=

:Menu
    echo.
    echo ====================================
    echo Select the step you want to perform:
    echo ====================================
    echo [1] File System MetaData       - Collects MFT, Boot, Amcache
    echo [2] Registry File              - Collects SAM, SYSTEM, SOFTWARE, SECURITY
    echo [3] Prefetch File              - Collects Prefetch
    echo [4] Event Log File             - Collects Event Log for target host
    echo [5] Recycle Bin Information    - Collects Recycle Bin Info
    echo [6] Browser history            - Collects Browser Cache, Cookie, Browser History, Download History
    echo [7] System Restore Point       - Collects Restore Point (or System Volume Information)
    echo [8] Portable System History    - Collects Portable Device Information
    echo [9] Link File                  - Collects Link File and JumpLists
    echo [a] RUN ALL STEPS
    echo [q] QUIT
    echo.
    set /p choice="You entered : "

    if not defined choice (
        goto :Menu
    ) else (
        set "steps="
        for %%x in (%choice%) do (
            if /i "%%x"=="q" (
                IF EXIST forecopy_handy.log (
                    move forecopy_handy.log %NONVOLATILE_DIR%\
                )
                for %%f in ("%kape%\%year%-%month%-%day%T*_ConsoleLog.txt") do (
                   move "%%f" "!NONVOLATILE_DIR!\"
                )
                echo %CASE% - %NAME% Inactive Data Collection finished >> %_TimeStamp%
                exit /b
            ) else if /i "%%x"=="a" (
                for /l %%i in (1, 1, %final_step%) do (
                    set "steps=!steps! %%i"
                )
            ) else (
                set "steps=!steps! %%x"
            )
        )
    for %%x in (!steps!) do (
        call :RUN_STEP_%%x
        )
    )
    goto :Menu



:RUN_STEP_1
    set _FileSystem=%NONVOLATILE_DIR%\FileSystem
    mkdir %_FileSystem%
    echo.
    echo Create FileSystem Data Directory
    echo [%timestamp%] Create FileSystem Data Directory >> %_TimeStamp%
    
    :RUN_STEP_1_INPUT
    echo.
    echo [RUN_STEP_1] Using forecopy or KAPE ? (input f or k)
    echo Quit (input q)
    echo.
    set /p _user_input_1="User Input: "
    
    if /i "%_user_input_1%"=="f" (
        goto RUN_STEP_1_Fore
    ) else if /i "%_user_input_1%"=="k" (
        goto RUN_STEP_1_KAPE
    ) else if /i "%_user_input_1%"=="q" (
        exit /b
    ) else (
        echo Invalid input. Please try again.
        GOTO RUN_STEP_1_INPUT
    )

:RUN_STEP_1_Fore
    echo.
    echo Acquring FileSystem Data...
    echo [%timestamp%] Acquring FileSystem Data... >> %_TimeStamp%
    forecopy_handy -m %_FileSystem%
    goto RUN_STEP_1_Hash

:RUN_STEP_1_KAPE
    %kape%\kape.exe --tsource %SystemDrive% --target FileSystem --tdest %_FileSystem% >NUL
    
    if "%net%"=="4" (
        goto RUN_STEP_1_NET4
    ) else if "%net%"=="6" (
        goto RUN_STEP_1_NET6
    ) else (
        goto RUN_STEP_1_Clear
    )

:RUN_STEP_1_NET4
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$MFT --csv %_FileSystem% --csvf "mft_parser.csv" >NUL
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Boot --csv %_FileSystem% --csvf "Boot_parser.csv" >NUL
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Extend\$J --csv %_FileSystem% --csvf "Extend_parser.csv" >NUL
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Secure_$SDS --csv %_FileSystem% --csvf "SDS_parser.csv" >NUL
    goto RUN_STEP_1_Hash

:RUN_STEP_1_NET6
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$MFT --csv %_FileSystem% --csvf "mft_parser.csv" >NUL
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Boot --csv %_FileSystem% --csvf "Boot_parser.csv" >NUL
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Extend\$J --csv %_FileSystem% --csvf "Extend_parser.csv" >NUL
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Secure_$SDS --csv %_FileSystem% --csvf "SDS_parser.csv" >NUL
    goto RUN_STEP_1_Hash

:RUN_STEP_1_Hash
    set _FileSystem_Hash=%_FileSystem%\Hash
    mkdir %_FileSystem_Hash%
    echo.
    echo CREATE FileSystem HASH DIRECTORY
    echo [%timestamp%] CREATE FileSystem HASH Directory >> %_TimeStamp%
    %hashdeep% -e -r %_FileSystem% > "%_FileSystem_Hash%\FileSystem_Hash.txt"
    echo.
    echo Acquring FileSystem Hash
    echo [%timestamp%] Acquring FileSystem Hash >> %_TimeStamp%
    echo.
    goto RUN_STEP_1_Clear

:RUN_STEP_1_Clear
    echo RUN_STEP_1 CLEAR
    exit /b

:RUN_STEP_2
    set Registry=%NONVOLATILE_DIR%\Registry
    mkdir %Registry%
    echo.
    echo Create Registry Directory 
    echo [%timestamp%] Create Registry Directory >> %_TimeStamp%

    :RUN_STEP_2_INPUT
    echo.
    echo [RUN_STEP_2] Using forecopy or KAPE ? (input f or k)
    echo Quit (input q)
    echo.
    set /p _user_input_2="User Input: "
    
    if /i "%_user_input_2%"=="f" (
        goto RUN_STEP_2_FORE
    ) else if /i "%_user_input_2%"=="k" (
        goto RUN_STEP_2_KAPE
    ) else if /i "%_user_input_2%"=="q" (
        exit /b
    ) else (
        echo Invalid input. Please try again.
        GOTO run_step_2_input
    )

:RUN_STEP_2_FORE
    echo.
    echo Acquring Registry...
    echo [%timestamp%] Acquring Registry >> %_TimeStamp%
    forecopy_handy -g %Registry%
    goto RUN_STEP_2_HASH

:RUN_STEP_2_KAPE
    %kape%\kape.exe --tsource %SystemDrive% --target RegistryHives --tdest %Registry% >NUL
    goto RUN_STEP_2_HASH

:RUN_STEP_2_HASH
    set _REGISTRY_HASH=%Registry%\Hash
    mkdir %_REGISTRY_HASH%
    echo.
    echo Create Registry Hash Directory 
    echo [%timestamp%] Create Registry Hash Directory >> %_TimeStamp%
    %hashdeep% -e -r %Registry%  > %REGISTRY_HASH%\REGISTRY_Hash.txt  
    echo.
    echo Calculate Registry Hash...
    echo [%timestamp%] Calculate Registry Hash... >> %_TimeStamp%
    goto RUN_STEP_2_CLEAR

:RUN_STEP_2_CLEAR
    echo RUN_STEP_2 CLEAR
    exit /b

:RUN_STEP_3
    set _Prefetch=%NONVOLATILE_DIR%\Prefetch
    mkdir %_Prefetch%
    echo.
    echo Create Prefetch Directory 
    echo [%timestamp%] Create Prefetch Directory >> %_TimeStamp%

    :RUN_STEP_3_INPUT
    echo.
    echo "[RUN_STEP_3] Using forecopy or KAPE ? (input f or k)"
    echo "Quit (input q) "
    echo.
    set /p _user_input_3="User Input: "
    
    if /i "%_user_input_3%"=="f" (
        goto RUN_STEP_3_FORE
    ) else if /i "%_user_input_3%"=="k" (
        goto RUN_STEP_3_KAPE
    ) else if /i "%_user_input_3%"=="q" (
        exit /b
    ) else (
        echo Invalid input. Please try again.
        GOTO RUN_STEP_3_INPUT
    )

:RUN_STEP_3_FORE
    echo.
    echo Acquring Prefetch...
    echo [%timestamp%] Acquring Prefetch... >> %_TimeStamp%
    forecopy_handy -p %_Prefetch%
    goto RUN_STEP_3_HASH

:RUN_STEP_3_KAPE
    %kape%\kape.exe --tsource %SystemDrive% --target Prefetch --tdest %_Prefetch% >NUL
    
    if "%net%"=="4" (
        goto RUN_STEP_3_NET4
    ) else if "%net%"=="6" (
        goto RUN_STEP_3_NET6
    ) else (
        goto RUN_STEP_3_HASH
    )
:RUN_STEP_3_NET4
    %pecmd% -d %_Prefetch%\%_FirstCharacter% --csv %_Prefetch% --csvf Prefetch.csv >NUL
    goto RUN_STEP_3_HASH

:RUN_STEP_3_NET6
    %pecmd% -d %_Prefetch%\%_FirstCharacter% --csv %_Prefetch% --csvf Prefetch.csv >NUL
    goto RUN_STEP_3_HASH

:RUN_STEP_3_HASH
    set Prefetch_Hash=%_Prefetch%\Hash
    mkdir %Prefetch_Hash%
    echo.
    echo Create Prefetch Hash Directory
    echo [%timestamp%] Create Prefetch Hash Directory >> %_TimeStamp%
    echo.
    %hashdeep% -e -r %_Prefetch% > %Prefetch_Hash%\Prefetch_Hash.txt
    echo Calculate Prefetch Hash...
    echo [%timestamp%] Calculate Prefetch Hash... >> %_TimeStamp%
    echo.
    goto RUN_STEP_3_Clear

:RUN_STEP_3_Clear
    echo RUN_STEP_3 CLEAR
    exit /b

:RUN_STEP_4
    set _eventLog=%NONVOLATILE_DIR%\EventLog
    mkdir %_eventLog%
    echo.
    echo Create EventLog Directory
    echo [%timestamp%] Create EventLog Directory >> %_TimeStamp%

    :RUN_STEP_INPUT_4
    echo.
    echo [RUN_STEP_4] Using forecopy or KAPE ? (input f or k)
    echo Quit (input q) 
    set /p _user_input_4="User Input: "

    if /i "%_user_input_4%"=="f" (
        goto RUN_STEP_4_FORE
    ) else if /i "%_user_input_4%"=="k" (
        goto RUN_STEP_4_KAPE
    ) else if /i "%_user_input_4%"=="q" (
        exit /b
    ) else (
        echo Invalid input. Please try again.
        GOTO RUN_STEP_INPUT_4
    )

:RUN_STEP_4_KAPE
    %kape%\kape.exe --tsource %SystemDrive% --target CombinedLogs --tdest %_eventLog% >NUL

    if "%net%"=="4" (
        goto RUN_STEP_4_NET4
    ) else if "%net%"=="6" (
        goto RUN_STEP_4_NET6
    ) else (
        goto Want_Server_log
    )

    :Want_Server_log
    echo.
    echo Want to collect server logs? (y or n)
    set /p _want_server_log=":"
    if /i "%_want_server_log%"=="y" (
        goto RUN_STEP_4_SERVER
    ) else if /i "%_want_server_log%"=="n" (
        goto RUN_STEP_4_HASH
    ) else (
        echo Invalid input. Please try again.
        GOTO Want_Server_log
    )

:RUN_STEP_4_NET4
    %evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\Application.evtx --csv %_eventLog% --csvf "Application_Parser.csv" >NUL
    %evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\Security.evtx --csv %_eventLog% --csvf "Security_Parser.csv" >NUL
    %evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\System.evtx --csv %_eventLog% --csvf "System_Parser.csv" >NUL
    %evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\Setup.evtx --csv %_eventLog% --csvf "Setup_Parser.csv" >NUL
    goto Want_Server_log

:RUN_STEP_4_NET6
    %evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\Application.evtx --csv %_eventLog% --csvf "Application_Parser.csv" >NUL
    %evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\Security.evtx --csv %_eventLog% --csvf "Security_Parser.csv" >NUL
    %evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\System.evtx --csv %_eventLog% --csvf "System_Parser.csv" >NUL
    %evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\Setup.evtx --csv %_eventLog% --csvf "Setup_Parser.csv" >NUL
    goto Want_Server_log

:RUN_STEP_4_SERVER
    set _Webserver=%_eventLog%\WebServer
    mkdir %_Webserver%
    echo.
    echo Create WebServer Directory 
    echo [%timestamp%] Create WebServer Directory >> %_TimeStamp%
    %kape%\kape.exe --tsource %SystemDrive% --target WebServers --tdest %_Webserver% >NUL
    goto RUN_STEP_4_HASH

:RUN_STEP_4_FORE
    echo.
    echo Acquring Event Log
    echo [%timestamp%] Acquring Event Log >> %_TimeStamp%
    forecopy_handy -e  %_eventLog%
    goto RUN_STEP_4_HASH

:RUN_STEP_4_HASH
    set eventHash=%_eventLog%\Hash
    mkdir %eventHash%
    echo.
    echo Create EventLog Hash Directory
    echo [%timestamp%] Create EventLog Hash Directory >> %_TimeStamp%
    echo.
    echo Calculate Event Hash...
    echo [%timestamp%] Calculate Event Hash... >> %_TimeStamp%
    %hashdeep% -e -r %_eventLog% > %eventHash%\EventLog_Hash.txt
    goto RUN_STEP_4_Clear

:RUN_STEP_4_Clear
    echo RUN_STEP_4 CLEAR
    exit /b

:RUN_STEP_5
    set recycleBin=%NONVOLATILE_DIR%\RecycleBin
    mkdir %recycleBin%
    echo.
    echo Create RecycleBin Directory
    echo [%timestamp%] Create RecycleBin Directory >> %_TimeStamp%

    set kapedir=%recycleBin%\kape
    mkdir %kapedir%
    echo.
    echo Acquring RecycleBin 
    echo [%timestamp%] Acquring RecycleBin >> %_TimeStamp%
    
    echo.
    :input_prompt
    echo "After creating the RecycleBin dump, pressing 'q' will generate the hash dump and terminate the current dump process"
    SET /P _user_input_5=Enter 'r' for rbmcd, 'x' for xcopy, 'k' for kape or 'q' for quit: 

    IF /I "%_user_input_5%"=="r" (
        if "%net%"=="4" (
            goto RecycleBin_net4
        ) else if "%net%"=="6" (
            goto RecycleBin_net6
        )
    ) ELSE IF /I "%_user_input_5%"=="x" (
        GOTO XCopyCommand
    ) ELSE IF /I "%_user_input_5%"=="k" (
        GOTO kape
    ) ELSE IF /I "%_user_input_5%"=="q" (
        GOTO RUN_STEP_5_HASH
    )
     ELSE (
        echo Invalid input. Please try again.
        GOTO input_prompt
    )

    :RecycleBin_net4
        echo rbcmd for net4 executed(Step5)
        %rbcmd% -d "%SystemDrive%\$Recycle.Bin" --csv %recycleBin% --csvf RecycleBin.csv >NUL
        echo [%timestamp%] rbcmd for net4 completed(Step5) >> %_TimeStamp%
        GOTO input_prompt

    :RecycleBin_net6
        echo rbcmd for net6 executed(Step5)
        %rbcmd% -d "%SystemDrive%\$Recycle.Bin" --csv %recycleBin% --csvf RecycleBin.csv >NUL
        echo [%timestamp%] rbcmd for net6 completed(Step5) >> %_TimeStamp%
        GOTO input_prompt

    :XCopyCommand
        echo xcopy executed(Step5)
        xcopy /e /h /y %SystemDrive%\$Recycle.Bin %recycleBin% 2>> %recycleBin%\recycleBin_collect_Error.log
        echo [%timestamp%] xcopy completed(Step5) >> %_TimeStamp%
        GOTO input_prompt

    :kape
        echo kape executed(Step5)
        %kape%\kape.exe --tsource %systemdrive% --target RecycleBin --tdest %kapedir% >NUL
        echo [%timestamp%] kape executed(Step5) >> %_TimeStamp%
        GOTO input_prompt

    :RUN_STEP_5_HASH
    set recycleBinHash=%recycleBin%\Hash
    mkdir %recycleBinHash%
    echo [%timestamp%] Create RecycleBin Hash Directory >> %_TimeStamp%
    echo.
    echo Calculate RecycleBin Hash...
    %hashdeep% -e -r %recycleBin% > %recycleBinHash%\RecycleBin_Hash.txt
    echo [%timestamp%] Calculate RecycleBin Hash... >> %_TimeStamp%

    echo RUN_STEP_5 CLEAR
    exit /b

:RUN_STEP_6
    set Browser=%NONVOLATILE_DIR%\Browser
    set _Edge=%Browser%\Edge
    set _Chromium=%Browser%\Chromium
    set _Chrome=%Browser%\Chrome
    set _IE=%Browser%\IE
    set _Firefox=%Browser%\Firefox
    set _WebCache=%Browser%\WebCache

    set _Edge_Hash=%_Edge%\Hash
    set _Chromium_Hash=%_Chromium%\Hash
    set _Chrome_Hash=%_Chrome%\Hash
    set _IE_Hash=%_IE%\Hash
    set _Firefox_Hash=%_Firefox%\Hash
    set _WebCache_Hash=%_WebCache%\Hash

    mkdir %Browser%
    echo.
    echo Create Browser Initial Directory
    echo [%timestamp%] Create Browser Directory >> %_TimeStamp%
    mkdir %_Chrome%
    echo [%timestamp%] Create Chrome Directory >> %_TimeStamp%
    mkdir %_Edge%
    echo [%timestamp%] Create Edge Directory >> %_TimeStamp%
    mkdir %_IE%
    echo [%timestamp%] Create IE Directory >> %_TimeStamp%
    mkdir %_Chromium%
    echo [%timestamp%] Create Chromium Directory >> %_TimeStamp%
    mkdir %_Firefox%
    echo [%timestamp%] Create Firefox Directory >> %_TimeStamp%
    mkdir %_WebCache%
    echo [%timestamp%] Create WebCache Directory >> %_TimeStamp%

    :browser_input
    echo "[RUN_STEP_6] Using forecopy or KAPE ? (input f or k)"
    set /p _user_input_6="User Input: "

    if /i "%_user_input_6%"=="f" (
        goto Browser_Forecopy
    ) else if /i "%_user_input_6%"=="k" (
        goto Browser_KAPE
    ) else (
        echo Invalid input. Please try again.
        GOTO browser_input
    )

:Browser_Forecopy
    :: Chrome
    echo.
    echo Acquring Chrome Data...
    echo [%timestamp%] Acquring Chrome Data... >> %_TimeStamp%

    forecopy_handy -r "%LocalAppData%\Google\Chrome\User Data\Default\Cache" %_Chrome%
    forecopy_handy -r "%LocalAppData%\Google\Chrome\User Data\Default\Download Service" %_Chrome%
    forecopy_handy -r "%LocalAppData%\Google\Chrome\User Data\Default\Network" %_Chrome%
    forecopy_handy -f "%LocalAppData%\Google\Chrome\User Data\Default\History" %_Chrome%

    :: Edge
    echo.
    echo Acquring Edge Data...
    echo [%timestamp%] Acquring Edge Data... >> %_TimeStamp%
    forecopy_handy -r "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache" %_Edge% 
    forecopy_handy -r "%LocalAppData%\Microsoft\Edge\User Data\Default\Download Service" %_Edge%
    forecopy_handy -r "%LocalAppData%\Microsoft\Edge\User Data\Default\Network" %_Edge%
    forecopy_handy -f "%LocalAppData%\Microsoft\Edge\User Data\Default\History" %_Edge%

    :: Firefox
    echo.
    echo Acquring Firefox Data...
    echo [%timestamp%] Acquring Firefox Data... >> %_TimeStamp%
    ::forecopy_handy -x %_Firefox%
    
    :: Firefox Cache
    :: xcopy /E /I "%LocalAppData%\Mozilla\Firefox\Profiles\*.default-release\cache2" "%_Firefox%\Cache"
    :: Firefox cookies
    :: xcopy /E /I "%AppData%\Mozilla\Firefox\Profiles\*.default-release\cookies.sqlite" "%_Firefox%\cookies"
    :: User's environment settings
    :: xcopy /E /I "%AppData%\Mozilla\Firefox\Profiles\*.default-release\prefs.js" "%_Firefox%\prefs"
    :: Site-specific permissions
    :: xcopy /E /I "%AppData%\Mozilla\Firefox\Profiles\*.default-release\permissions.sqlite" "%_Firefox%\permissions"
    :: Firefox History, Downloads, Network Error Logging
    :: xcopy /E /I "%AppData%\Mozilla\Firefox\Profiles\*.default-release\places.sqlite" "%_Firefox%\history_downloads_NEL"

    :: Copy entire Firefox profile directories
    xcopy /E /I "%LocalAppData%\Mozilla\Firefox\Profiles" "%_Firefox%\LocalFirefoxProfiles"
    xcopy /E /I /EXCLUDE:%ETC%\browser_exclude.txt "%AppData%\Mozilla\Firefox\Profiles" "%_Firefox%\RoamingFirefoxProfiles"

    :: WebCache
    echo.
    echo Acquring WebCache.DAT...
    echo [%timestamp%] Acquring WebCache.DAT... >> %_TimeStamp%
    forecopy_handy -f "%LocalAppData%\Microsoft\Windows\WebCache\WebCacheV01.DAT" %_WebCache%

    goto Browser_Hash

:Browser_KAPE
    %kape%\kape.exe --tsource %SystemDrive% --target Chrome --tdest %_Chrome% >NUL
    %kape%\kape.exe --tsource %SystemDrive% --target ChromeExtensions --tdest %_Chrome% >NUL
    %kape%\kape.exe --tsource %SystemDrive% --target ChromeFileSystem --tdest %_Chrome% >NUL
    echo [%timestamp%] Acquring Chrome Data... >> %_TimeStamp% 
    
    %kape%\kape.exe --tsource %SystemDrive% --target Edge --tdest %_Edge% >NUL
    echo [%timestamp%] Acquring Edge Data... >> %_TimeStamp% 

    %kape%\kape.exe --tsource %SystemDrive% --target Firefox --tdest %_Firefox% >NUL
    echo [%timestamp%] Acquring Firefox Data... >> %_TimeStamp% 

    %kape%\kape.exe --tsource %SystemDrive% --target InternetExplorer --tdest %_IE% >NUL
    echo [%timestamp%] Acquring InternetExplorer Data... >> %_TimeStamp% 

    %kape%\kape.exe --tsource %SystemDrive% --target EdgeChromium --tdest %_Chromium% >NUL
    echo [%timestamp%] Acquring Chromium Data... >> %_TimeStamp% 

    %kape%\kape.exe --tsource %SystemDrive% --target BrowserCache --tdest %_WebCache% >NUL
    echo [%timestamp%] Acquring BrowserCache Data... >> %_TimeStamp% 

    goto Browser_Hash

:Browser_Hash
    mkdir %_Chrome_Hash%
    echo [%timestamp%] Create Chrome Hash Directory >> %_TimeStamp%
    echo Calculate Chrome Hash
    echo [%timestamp%] Calculate Chrome Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Chrome% > %_Chrome_Hash%\Chrome_Hash.txt

    mkdir %_Firefox_Hash%
    echo [%timestamp%] Create Firefox Hash Directory >> %_TimeStamp%
    echo Calculate Firefox Hash
    echo [%timestamp%] Calculate Firefox Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Firefox% > %_Firefox_Hash%\Firefox_Hash.txt 

    mkdir %_Edge_Hash%
    echo [%timestamp%] Create Edge Hash Directory >> %_TimeStamp%
    echo Calculate Edge Hash
    echo [%timestamp%] Calculate Edge Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Edge% > %_Edge_Hash%\Edge_Hash.txt 
    
    mkdir %_IE_Hash%
    echo [%timestamp%] Create IE Hash Directory >> %_TimeStamp%
    echo Calculate IE Hash
    echo [%timestamp%] Calculate IE Hash >> %_TimeStamp%
    %hashdeep% -e -r %_IE% > %_IE_Hash%\IE_Hash.txt 
    
    mkdir %_Chromium_Hash%
    echo [%timestamp%] Create Chromium Hash Directory >> %_TimeStamp%
    echo Calculate Whale Hash
    echo [%timestamp%] Calculate Chromium Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Chromium% > %_Chromium_Hash%\Chromium_Hash.txt 

    mkdir %_WebCache_Hash%
    echo [%timestamp%] Create WebCache Hash Directory >> %_TimeStamp%
    echo Calcultae WebCache Hash
    echo [%timestamp%] Calculate WebCache Hash >> %_TimeStamp%
    %hashdeep% -e -r %_WebCache% > %_WebCache_Hash%\WebCache_Hash.txt

    echo RUN_STEP_6 CLEAR
    echo [%timestamp%] RUN_STEP_6 CLEAR>> %_TimeStamp%
    exit /b

:RUN_STEP_7
    set _restore=%NONVOLATILE_DIR%\Restore
    mkdir %_restore%
    echo.
    echo Create Restore Directory
    echo [%timestamp%] Create Restore Directory >> %_TimeStamp%
    ::forecopy_handy -dr %SYSTEMROOT%\system32\Restore %_restore%
    xcopy /E /H /I "%SYSTEMROOT%\system32\Restore" "%_restore%"
    echo [%timestamp%] Restore File >> %_TimeStamp%
    ::forecopy_handy -dr %HOMEDRIVE%\System Volume Information\_restore{guid} %_restore%

    echo RUN_STEP_7 CLEAR
    exit /b

:RUN_STEP_8
    set _USBDetective=%NONVOLATILE_DIR%\USBDetective
    set _USBDetective_Hash=%_USBDetective%\Hash
    echo.
    mkdir %_USBDetective%
    echo Create USBDetective Directory
    echo [%timestamp%] Create USBDetective Directory >> %_TimeStamp%
    
    :run_step_8_input
    echo.
    echo "Using forecopy or KAPE ? (input f or k)"
    echo "Quit (input q) "
    set /p _user_input_8="User Input: "
    
    if /i "%_user_input_8%"=="f" (
        goto USB_Forecopy
    ) else if /i "%_user_input_8%"=="k" (
        goto USB_KAPE
    ) else if /i "%_user_input_8%"=="q" (
        exit /b
    ) else (
        echo Invalid input. Please try again.
        GOTO run_step_8_input
    )

:USB_Forecopy
    echo.
    echo Acquring USB Logs Information...
    echo [%timestamp%] Acquring Driver Information... >> %_TimeStamp%
    forecopy_handy -t %_USBDetective%
    goto USB_Hash

:USB_KAPE
    %kape%\kape.exe --tsource %SystemDrive% --target USBDevicesLogs --tdest %_USBDetective%
    goto USB_Hash

:USB_Hash
    mkdir %_USBDetective_Hash%
    echo.
    echo Create USBDetect Hash Directory
    echo [%timestamp%] Create Driver Hash Direcotry >> %_TimeStamp%
    
    %hashdeep% -e -r %_USBDetective% > %_USBDetective_Hash%\USB_Hash.txt

    echo.
    echo Calculate USBDetective Hash...
    echo [%timestamp%] Calculate USBDetective Hash... >> %_TimeStamp%
    goto RUN_STEP_8_Clear

:RUN_STEP_8_Clear
    echo RUN_STEP_8 CLEAR
    exit /b


:RUN_STEP_9
    set _Recent=%NONVOLATILE_DIR%\Recent
    mkdir %_Recent%
    echo.
    echo Create Recent Directory
    echo [%timestamp%] Create Recent Directory >> %_TimeStamp%
    echo.
    echo Acquring Recent Data ...
    echo [%timestamp%] Acquring Recent Data... >> %_Timestamp%
    forecopy_handy -r "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Recent" %_Recent%

    if  "%net%"=="4" (
        goto Recent_net4
    ) else if "%net%"=="6" (
        goto Recent_net6
    ) else (
        goto RUN_STEP_9_Clear
    )

:Recent_net4
    %lecmd% -d "%userprofile%\Desktop" --csv %_Recent% --csvf "Desktop_Parser.csv" >NUL
    %lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Recent" --csv %_Recent% --csvf "Recent_Parser.csv" >NUL
    %lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" --csv %_Recent% --csvf "Startup_Parser.csv" >NUL
    %lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" --csv %_Recent% --csvf "QuickLaunch_Parser.csv" >NUL

    :: Jump List 
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestination
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent\CustomDestination
    %jlecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Recent" --csv %_Recent% --csvf "JumpList.csv" >NUL
    echo [%timestamp%] LECmd_net4  >> %_TimeStamp%
    goto RUN_STEP_9_Clear

:Recent_net6
    %lecmd% -d "%userprofile%\Desktop" --csv %_Recent% --csvf "Desktop_Parser.csv"
    %lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Recent" --csv %_Recent% --csvf "Recent_Parser.csv" >NUL
    %lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" --csv %_Recent% --csvf "Startup_Parser.csv" >NUL
    %lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" --csv %_Recent% --csvf "QuickLaunch_Parser.csv" >NUL

    :: Jump List
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestination
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent\CustomDestination
    %jlecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Recent" --csv %_Recent% --csvf "JumpList.csv" >NUL
    echo [%timestamp%] LECmd_net6  >> %_TimeStamp%
    goto RUN_STEP_9_Clear

:Recent_Hash
    set _Recent_Hash=%_Recent%\Hash
    mkdir _Recent_Hash
    echo.
    echo Create Recent Hash Directory
    echo [%timestamp%] Create Recent Hash Directory
    echo.
    %hashdeep% -e -r %_Recent% > %_Recent_Hash%\Recent_Hash.txt
    echo Calculate Recent Hash...
    echo [%timestamp%] Calculate Recent Hash...
    echo.
    goto RUN_STEP_9_Clear

:RUN_STEP_9_Clear
    echo RUN_STEP_9 CLEAR
    exit /b
echo [%timestamp%] End Time >> %_TimeStamp%
endlocal

