@echo off
setlocal enabledelayedexpansion

SET "curDir=%~dp0"
SET "ETC=%~dp0etc"
set "sysinternals=%~dp0sysinternalsSuite"
SET "HASH=%~dp0HASH"
set "dump=%~dp0Memory_Dump_Tool"
set "kape=%~dp0kape"
SET "PATH=%curDir%;%ETC%;%sysinternals%;%HASH%;%dump%;%kape%;%PATH%"

set "CASE=%~1"
set "NAME=%~2"

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
set foldername=%3%computername%_%timestamp%
mkdir "%foldername%"
echo CREATE %foldername% DIRECTORY 

:: LOG TIMESTAMP
set _TimeStamp=%foldername%\TimeStamp.log
::echo START TIME : %timestamp%
echo [%timestamp%] Inactive Script START TIME >> %_TimeStamp%

:: CREATE NONVOLATILE DATA DIRECTORY
set NONVOLATILE_DIR=%foldername%\NONVOLATILE
mkdir %NONVOLATILE_DIR%
echo [%timestamp%] CREATE NONVOLATILE DIRECTORY >> %_TimeStamp%

:: INPUT CASE, NAME
:INPUT_CASE
    echo [%timestamp%] CASE: %CASE% >> %_TimeStamp%

:INPUT_NAME
    echo [%timestamp%] NAME: %NAME% >> %_TimeStamp%

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

set final_step=10
set choice=

:Menu
    echo.
    echo ====================================
    echo Select the step you want to perform:
    echo ====================================
    echo [1] File System MetaData - MFT, Boot, Amcache
    echo [2] Registry File - SAM, SYSTEM, SOFTWARE, SECURITY
    echo [3] Prefetch File
    echo [4] Event Log File
    echo [5] Recycle Bin Information 
    echo [6] Browser history
    echo [7] Temporary File
    echo [8] System Restore Point
    echo [9] Portable System History
    echo [10] Link File
    echo [a] RUN ALL STEPS
    echo [q] QUIT
    set /p choice="You entered : "

    if not defined choice (
        goto Menu
    ) else (
        set "steps="
        for %%x in (%choice%) do (
            if /i "%%x"=="q" (
                IF EXIST forecopy_handy.log (
                    move forecopy_handy.log %NONVOLATILE_DIR%\
                )
                goto END_NONVOLATILE_SCRIPT
            ) else if /i "%%x"=="a" (
                for /l %%i in (1, 1, %final_step%) do (
                    set "steps=!steps! %%i"
                )
            ) else (
                set "steps=!steps! %%x"
            )
        )
    )
    for %%x in (!steps!) do (
        set "requires_credentials=0"
        for %%y in (5 6 8 10) do (
            if "%%x"=="%%y" (
                set "requires_credentials=1"
            )
        )
        if "!requires_credentials!"=="1" (
            call :get_user_credentials
        )
        call :run_step_%%x
    )
    goto Menu

:get_user_credentials
    if not defined user_id (
        set /p "user_id=Please input the user ID of someone with administrator privileges: "
        if not defined user_id (
            echo you didn't input user ID, plz Input again
            goto get_user_credentials
        )
        set /p "user_pw=Please input the password for the user with administrator privileges (leave empty if none): "
        "%psexec%" -u %user_id% -p %user_pw% -accepteula -i -s cmd.exe /c "echo account validation verified  & pause" 
        if ERRORLEVEL 1 (
            echo PsExec failed. Please try again.
            goto get_user_credentials
        )
        if defined user_pw (
            set psexec_opt="%psexec%" -u !user_id! -p !user_pw!
        ) else (
            set psexec_opt="%psexec%" -u !user_id!
        )
        echo psexec_opt is set to: !psexec_opt!
    )
    goto :eof

:: MFT
:run_step_1
    set _MetaData=%NONVOLATILE_DIR%\_Metadata
    mkdir %_MetaData%
    echo [%timestamp%] Create MetaData Directory >> %_TimeStamp%

    set _MFT=%_MetaData%\_MFT
    mkdir %_MFT%
    echo CREATE MFT DIRECTORY
    echo [%timestamp%] CREATE MFT DIRECTORY >> %_TimeStamp%
    forecopy_handy -m %_MFT%
    echo Acquring MFT FILE 
    echo [%timestamp%] Acquring MFT File >> %_TimeStamp%

    :: MFT HASH
    set _MFT_HASH=%_MFT%\HASH
    mkdir %_MFT_HASH%
    echo CREATE MFT HASH DIRECTORY
    echo [%timestamp%] CREATE MFT HASH Directory >> %_TimeStamp%
    %hashdeep% -e "%_MFT%\mft\$MFT" > "%_MFT_HASH%\_MFT_HASH.txt"
    echo Acquring MFT FILE HASH 
    echo [%timestamp%] Acquring MFT FILE HASH >> %_TimeStamp%

    :: $Boot
    set _Boot=%_MetaData%\_Boot
    mkdir %_Boot%
    echo CREATE $BOOT DIRECTORY 
    echo [%timestamp%] CREATE BOOT FILE DIRECTORY >> %_TimeStamp%
    forecopy_handy -f %SystemDrive%\$Boot %_Boot%
    echo Acquring $BOOT FILE...
    echo [%timestamp%] Acquring BOOT FILE... >> %_TimeStamp%

    set _Boot_Hash=%_Boot%\HASH
    mkdir %_Boot_Hash%
    echo CREATE $BOOT HASH DIRECTORY
    echo [%timestamp%] CREATE BOOT HASH DIRECTORY >> %_TimeStamp%
    %hashdeep% -e "%_Boot%\$Boot" > "%_Boot_Hash%\_Boot_HASH.txt"
    
    if "%net%"=="4" (
        goto MFTParser_net4
    ) else if "%net%"=="6" (
        goto MFTParser_net6
    ) else (
        goto RUN_STEP_1_Clear
    )

:MFTParser_net4
    %mftecmd% -f %_MFT%\mft\$MFT --csv %_MFT% --csvf "mft_parser.csv"
    goto RUN_STEP_1_Clear

:MFTParser_net6
    %mftecmd% -f %_MFT%\mft\$MFT --csv %_MFT% --csvf "mft_parser.csv"
    goto RUN_STEP_1_Clear

:RUN_STEP_1_Clear
    echo RUN_STEP_1 CLEAR
    exit /b

::VBR
::set VBR_DIR=%NONVOLATILE_DIR%\VBR
::mkdir %VBR_DIR%
::forecopy_handy -f %SystemDrive%\$Boot %VBR_DIR%
::echo [%timestamp%] VBR >> %_TimeStamp%

:: VBR HASH 
::set VBR_HASH=%VBR_DIR%\HASH
::mkdir %VBR_HASH%
::echo [%timestamp%] CREATE VBR HASH Directory >> %_TimeStamp%
::%hashdeep% -e "%VBR_DIR%\$Boot" > "%VBR_HASH%\BOOT_HASH.txt"
::echo [%timestamp%] VBR HASH >> %_TimeStamp%


:: REGISTRY
:: -g option : SAM, SYSTEM, SECURITY, SOFTWARE, DEFAULT, NTUSER.DAT 획득 

:run_step_2
    set Registry=%NONVOLATILE_DIR%\_Registry
    mkdir %Registry%
    echo [%timestamp%] Create Registry Directory >> %_TimeStamp%
    forecopy_handy -g %Registry%
    echo Acquring Registry...
    echo [%timestamp%] Acquring Registry >> %_TimeStamp%

:: HASH
    set REGISTRY_HASH=%Registry%\_Hash
    mkdir %REGISTRY_HASH%
    echo [%timestamp%] Create Registry Hash Directory >> %_TimeStamp%
    %hashdeep% -e -r %Registry%\registry  > %REGISTRY_HASH%\_REGISTRY_Hash.txt  
    echo Calculate Registry Hash...
    echo [%timestamp%] Calculate Registry Hash... >> %_TimeStamp%

    echo RUN_STEP_2 CLEAR
    exit /b

:: PreFetch OR SuperFetch
:run_step_3
    set fetch=%NONVOLATILE_DIR%\_Prefetch
    mkdir %fetch%
    echo [%timestamp%] Create Prefetch Directory >> %_TimeStamp%
    forecopy_handy -p %fetch%
    echo.
    echo Acquring Prefetch...
    echo [%timestamp%] Acquring Prefetch... >> %_TimeStamp% 

    :: HASH
    set fetchHash=%fetch%\_Hash
    mkdir %fetchHash%
    echo [%timestamp%] Create Prefetch Hash Directory >> %_TimeStamp%
    echo.
    %hashdeep% -e -r %fetch%\prefetch > %fetchHash%\_Prefetch_Hash.txt
    echo.
    echo Calculate Prefetch Hash...

    echo RUN_STEP_3 CLEAR
    exit /b

::  $LogFile (C:\Windows\System32\winevt\Logs)
::  C:\Windows\System32\winevt\Logs\Application.evtx
:: Records the events of user applications including software
::  C:\Windows\System32\winevt\Logs\Security.evtx 
: Records various logs such as security-related event logs, Windows logon, and network
::  C:\Windows\System32\winevt\Logs\System.evtx
:: Records information on service run status, file system, device errors, etc.
::  C:\Windows\System32\winevt\Logs\Setup.evtx
:: Records the events that occur when an application is installed, whether the program is installed well, compatibility-related information

:run_step_4
    set eventLog=%NONVOLATILE_DIR%\_EventLog
    mkdir %eventLog%
    echo [%timestamp%] Create EventLog Directory >> %_TimeStamp%
    forecopy_handy -e  %eventLog%
    echo.
    echo Acquring Event Log
    echo [%timestamp%] Acquring Event Log >> %_TimeStamp%

    :: Hash
    set eventHash=%eventLog%\_Hash
    mkdir %eventHash%
    echo [%timestamp%] Create EventLog Hash Directory >> %_TimeStamp%
    echo.
    %hashdeep% -e -r %eventLog%\eventlogs\Logs > %eventHash%\_Event_Hash.txt
    echo.
    echo Calculate Event Hash...
    echo [%timestamp%] Calculate Event Hash... >> %_TimeStamp%

    echo RUN_STEP_4 CLEAR
    exit /b

:run_step_5
    set recycleBin=%NONVOLATILE_DIR%\_RecycleBin
    mkdir %recycleBin%
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
        ::%rbcmd% -d "%SystemDrive%\$Recycle.Bin" --csv %recycleBin% --csvf RecycleBin.csv
        ::"%psexec%" -u %user_id% -p %user_pw% -accepteula -i -s cmd.exe /c "%rbcmd% -d "%SystemDrive%\$Recycle.Bin" --csv %recycleBin% --csvf RecycleBin.csv & pause"
        !psexec_opt! -accepteula -i -s cmd.exe /c "%rbcmd% -d "%SystemDrive%\$Recycle.Bin" --csv %recycleBin% --csvf RecycleBin.csv & pause"
        echo [%timestamp%] rbcmd for net4 completed(Step5) >> %_TimeStamp%
        GOTO input_prompt

    :RecycleBin_net6
        echo rbcmd for net6 executed(Step5)
        ::%rbcmd% -d "%SystemDrive%\$Recycle.Bin" --csv %recycleBin% --csvf RecycleBin.csv
        ::"%psexec%" -u %user_id% -p %user_pw% -accepteula -i -s cmd.exe /c "%rbcmd% -d "%SystemDrive%\$Recycle.Bin" --csv %recycleBin% --csvf RecycleBin.csv & pause"
        !psexec_opt! -accepteula -i -s cmd.exe /c "%rbcmd% -d "%SystemDrive%\$Recycle.Bin" --csv %recycleBin% --csvf RecycleBin.csv & pause"
        echo [%timestamp%] rbcmd for net6 completed(Step5) >> %_TimeStamp%
        GOTO input_prompt

    :XCopyCommand
        echo xcopy executed(Step5)
        ::xcopy /e /h /y %SystemDrive%\$Recycle.Bin %recycleBin% 2>> %recycleBin%\recycleBin_collect_Error.log
        ::"%psexec%" -u %user_id% -p %user_pw% -accepteula -i -s cmd.exe /c "xcopy /e /h /y %SystemDrive%\$Recycle.Bin %recycleBin% 2>> %recycleBin%\recycleBin_collect_Error.log & pause"
        !psexec_opt! -accepteula -i -s cmd.exe /c "xcopy /e /h /y %SystemDrive%\$Recycle.Bin %recycleBin% 2>> %recycleBin%\recycleBin_collect_Error.log & pause"
        echo [%timestamp%] xcopy completed(Step5) >> %_TimeStamp%
        GOTO input_prompt

    :kape
        set tsource=C:\
        set target=RecycleBin_DataFiles, RecycleBin_InfoFiles
        echo kape executed(Step5)
        ::%kape%\kape.exe --tsource %tsource% --target %target% --tdest %kapedir%
        !psexec_opt! -accepteula -i -s cmd.exe /c "%kape%\kape.exe --tsource %tsource% --target %target% --tdest %kapedir%"
        echo [%timestamp%] kape executed(Step5) >> %_TimeStamp%
        GOTO input_prompt

    :RUN_STEP_5_HASH
    set recycleBinHash=%recycleBin%\_Hash
    mkdir %recycleBinHash%
    echo [%timestamp%] Create RecycleBin Hash Directory >> %_TimeStamp%
    echo.
    echo Calculate RecycleBin Hash...
    %hashdeep% -e -r %recycleBin% > %recycleBinHash%\_RecycleBin_Hash.txt
    echo [%timestamp%] Calculate RecycleBin Hash... >> %_TimeStamp%

    echo RUN_STEP_5 CLEAR
    exit /b

:run_step_6
::브라우저 사용 흔적
    set Browser=%NONVOLATILE_DIR%\_Browser
    set _Edge=%Browser%\Edge
    set _Whale=%Browser%\Whale
    set _Chrome=%Browser%\Chrome
    set _Firefox=%Browser%\Firefox
    set _WebCache=%Browser%\WebCache

    set _Edge_Hash=%_Edge%\Hash
    set _Whale_Hash=%_Whale%\Hash
    set _Chrome_Hash=%_Chrome%\Hash
    set _Firefox_Hash=%_Firefox%\Hash
    set _WebCache_Hash=%_WebCache%\Hash

    mkdir %Browser%
    echo Create Browser Initial Directory
    echo [%timestamp%] Create Browser Directory >> %_TimeStamp%
    mkdir %_Chrome%
    echo [%timestamp%] Create Chrome Directory >> %_TimeStamp%
    mkdir %_Edge%
    echo [%timestamp%] Create Edge Directory >> %_TimeStamp%
    mkdir %_Whale%
    echo [%timestamp%] Create Whale Directory >> %_TimeStamp%
    mkdir %_Firefox%
    echo [%timestamp%] Create Firefox Directory >> %_TimeStamp%
    mkdir %_WebCache%
    echo [%timestamp%] Create WebCache Directory >> %_TimeStamp%

    :: Chrome 
    echo Acquring Chrome Data...
    echo [%timestamp%] Acquring Chrome Data... >> %_TimeStamp%
    forecopy_handy -dr "%LocalAppData%\Google\Chrome\User Data\Default\Cache" %_Chrome%
    forecopy_handy -dr "%LocalAppData%\Google\Chrome\User Data\Default\Download Service" %_Chrome%
    forecopy_handy -dr "%LocalAppData%\Google\Chrome\User Data\Default\Network" %_Chrome%
    forecopy_handy -f "%LocalAppData%\Google\Chrome\User Data\Default\History" %_Chrome%

    :: Naver Whale
    echo Acquring Whale Data...
    echo [%timestamp%] Acquring Whale Data... >> %_TimeStamp%
    forecopy_handy -dr "%LocalAppData%\Naver\Naver Whale\User Data\Default\Cache" %_Whale% 2>> %Browser%\Error.log
    forecopy_handy -dr "%LocalAppData%\Naver\Naver Whale\User Data\Default\Download Service" %_Whale% 2>> %Browser%\Error.log
    forecopy_handy -dr "%LocalAppData%\Naver\Naver Whale\User Data\Default\Network" %_Whale% 2>> %Browser%\Error.log
    forecopy_handy -f "%LocalAppData%\Naver\Naver Whale\User Data\Default\History" %_Whale% 2>> %Browser%\Error.log

    :: Edge
    echo Acquring Edge Data...
    echo [%timestamp%] Acquring Edge Data... >> %_TimeStamp%
    forecopy_handy -dr "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache" %_Edge% 
    forecopy_handy -dr "%LocalAppData%\Microsoft\Edge\User Data\Default\Download Service" %_Edge%
    forecopy_handy -dr "%LocalAppData%\Microsoft\Edge\User Data\Default\Network" %_Edge%
    forecopy_handy -f "%LocalAppData%\Microsoft\Edge\User Data\Default\History" %_Edge%

    :: Firefox
    echo Acquring Firefox Data...
    echo [%timestamp%] Acquring Firefox Data... >> %_TimeStamp%
    mkdir %_Firefox%\LocalFirefoxProfiles
    echo [%timestamp%] Create LocalFirefoxProfiles >> %_TimeStamp%
    mkdir %_Firefox%\RoamingFirefoxProfiles
    echo [%timestamp%] Create RoamingFirefoxProfiles >> %_TimeStamp%
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
    echo checking if %LocalAppData%\Mozilla\Firefox\Profiles exists
    IF EXIST "%LocalAppData%\Mozilla\Firefox\Profiles" (
        echo Copying LocalFirefoxProfiles...
        ::xcopy /E /I "%LocalAppData%\Mozilla\Firefox\Profiles" "%_Firefox%\LocalFirefoxProfiles"
        !psexec_opt! -accepteula -i -s cmd.exe /c "xcopy /E /I "%LocalAppData%\Mozilla\Firefox\Profiles" "%_Firefox%\LocalFirefoxProfiles" && echo %errorlevel%"
        echo Finished copying LocalFirefoxProfiles.
    ) ELSE (
        echo specified Firefox directory %LocalAppData%\Mozilla\Firefox\Profiles doesn't exist
        echo "%LocalAppData%\Mozilla\Firefox\Profiles Directory does not exist." >> %Browser%\Error.log
    )
    
    echo checking if %AppData%\Mozilla\Firefox\Profiles
    IF EXIST "%AppData%\Mozilla\Firefox\Profiles" (
        REM The batch script checks if Firefox is currently running. 
        tasklist /FI "IMAGENAME eq firefox.exe" 2>NUL | find /I /N "firefox.exe" >NUL 2>&1
        if "%ERRORLEVEL%"=="0" (
            REM If it is running, the script performs an xcopy operation, excluding the specified file and copying all the others.
            ::xcopy /E /I /EXCLUDE:%ETC%\browser_exclude.txt "%AppData%\Mozilla\Firefox\Profiles" "%_Firefox%\RoamingFirefoxProfiles"
            REM Due to memory shortage errors with xcopy, the operation is performed using robocopy instead
            echo Copying Roaming Firefox Profiles...
            !psexec_opt! -accepteula -i -s cmd.exe /c "robocopy "%AppData%\Mozilla\Firefox\Profiles" "%_Firefox%\RoamingFirefoxProfiles" /E /XF parent.lock"
            echo Finished copying Roaming Firefox Profiles without parent.lock.
        ) else (
            ::xcopy /E /I "%AppData%\Mozilla\Firefox\Profiles" "%_Firefox%\RoamingFirefoxProfiles"
            echo Copying Roaming Firefox Profiles...
            !psexec_opt! -accepteula -i -s cmd.exe /c "robocopy "%AppData%\Mozilla\Firefox\Profiles" "%_Firefox%\RoamingFirefoxProfiles" /E"
            echo Finished copying Roaming Firefox Profiles.
        )
    ) ELSE (
            echo specified Firefox directory %AppData%\Mozilla\Firefox\Profiles doesn't exist
            echo "%AppData%\Mozilla\Firefox\Profiles Directory does not exist." >> %Browser%\Error.log
    )


    :: WebCache
    echo Acquring WebCache.DAT...
    echo [%timestamp%] Acquring WebCache.DAT... >> %_TimeStamp%
    forecopy_handy -f "%LocalAppData%\Microsoft\Windows\WebCache\WebCacheV01.DAT" %_WebCache%

    :: Hash
    mkdir %_Chrome_Hash%
    echo [%timestamp%] Create Chrome Hash Directory >> %_TimeStamp%
    echo Calculate Chrome Hash
    echo [%timestamp%] Calculate Chrome Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Chrome% > %_Chrome_Hash%\Chrome_Hash.txt


    mkdir %_Firefox_Hash%
    echo [%timestamp%] Create Firefox Hash Directory >> %_TimeStamp%
    echo Calculate Firefox Hash
    echo [%timestamp%] Calculate Firefox Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Firefox% > %_Firefox_Hash%\Firefox_Hash.txt 2>> %Browser%\Error.log


    mkdir %_Edge_Hash%
    echo [%timestamp%] Create Edge Hash Directory >> %_TimeStamp%
    echo Calculate Edge Hash
    echo [%timestamp%] Calculate Edge Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Edge% > %_Edge_Hash%\Edge_Hash.txt 

    
    mkdir %_Whale_Hash%
    echo [%timestamp%] Create Whale Hash Directory >> %_TimeStamp%
    echo Calculate Whale Hash
    echo [%timestamp%] Calculate Whale Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Whale% > %_Whale_Hash%\Whale_Hash.txt 2>> %Browser%\Error.log

    mkdir %_WebCache_Hash%
    echo [%timestamp%] Create WebCache Hash Directory >> %_TimeStamp%
    echo Calcultae WebCache Hash
    echo [%timestamp%] Calculate WebCache Hash >> %_TimeStamp%
    %hashdeep% %_WebCache%\WebCacheV01.DAT > %_WebCache_Hash%\WebCache_Hash.txt

    echo RUN_STEP_6 CLEAR
    echo [%timestamp%] RUN_STEP_6 CLEAR>> %_TimeStamp%
    exit /b

:run_step_7
    :: $UsnJrnl$J
    :: $LogFile
    set _TempFile=%NONVOLATILE_DIR%\_Temp
    mkdir %_TempFile%
    echo Create Temp Directory 
    echo [%timestamp%] Create Temp Directory  >> %_TimeStamp%
    ::forecopy_handy -dr %temp% %_TempFile%
    :prompt
    echo Have you ever run CyLR before? If not, press 1 to execute. Otherwise, press 2.
    SET /P _user_input_7=Please enter 1 or 2: 

    IF /I "%_user_input_7%"=="1" GOTO proceed
    IF /I "%_user_input_7%"=="2" GOTO STEP_7_END
    echo Invalid input. Please try again.
    GOTO prompt

    :proceed
    echo Acquring Temp Data...
    !psexec_opt! -accepteula -i -s cmd.exe /c "call %CyLR% --usnjrnl -od %_TempFile% -of temp_dump.zip"
    echo [%timestamp%] Acquring Temp Data... >> %_TimeStamp%

    set _TempFile_Hash=%_TempFile%\_Hash
    mkdir %_TempFile_Hash%
    echo Create TempFile Hash Direcotry
    echo [%timestamp%] Create TempFile Hash Direcotry >> %_TimeStamp%
    %hashdeep% -e -r %_TempFile% > %_TempFile_Hash%\_Temp_Hash.txt
    echo Calculate Temp Hash >> %_TimeStamp%
    echo [%timestamp%] Calculate Temp Hash >> %_TimeStamp%

    :STEP_7_END
    echo RUN_STEP_7 CLEAR
    echo [%timestamp%] RUN_STEP_7 CLEAR >> %_TimeStamp%
    exit /b

:run_step_8
::SET GUID
::    set guid=
::    for /f "tokens=3" %%g in ('reg query HKLM\SOFTWARE\Microsoft\Cryptography /v MachineGuid') do (
::        set guid=%%g
::    )
    set _restore=%NONVOLATILE_DIR%\_Restore
    mkdir %_restore%
    echo [%timestamp%] Create Restore Directory >> %_TimeStamp%
    ::xcopy /E /H /I "%SYSTEMROOT%\system32\Restore" "%_restore%"
    !psexec_opt! -accepteula -i -s cmd.exe /c "xcopy /E /H /I "%SYSTEMROOT%\system32\Restore" "%_restore%" & pause"
    echo [%timestamp%] Restore File >> %_TimeStamp%
    ::forecopy_handy -dr %HOMEDRIVE%\System Volume Information\_restore{guid} %_restore%

    echo RUN_STEP_8 CLEAR
    exit /b

:: SYSTEM32/drivers/etc files
:run_step_9
    set _Driver=%NONVOLATILE_DIR%\_Driver
    set _Driver_Hash=%_Driver%\_Hash
    mkdir %_Driver%
    echo Create Driver Directory
    echo [%timestamp%] Create Driver Directory >> %_TimeStamp%
    forecopy_handy -t %_Driver%
    echo Acquring Driver Information...
    echo [%timestamp%] Acquring Driver Information... >> %_TimeStamp%

    mkdir %_Driver_Hash%
    echo Create Driver Hash Directory
    echo [%timestamp%] Create Driver Hash Direcotry >> %_TimeStamp%
    
    %hashdeep% -e -r %_Driver% > %_Driver_Hash%\_Driver_Hash.txt

    echo Calculate Driver Hash...
    echo [%timestamp%] Calculate Driver Hash... >> %_TimeStamp%

    echo RUN_STEP_9 CLEAR
    exit /b

:: RECENT LNKs and JUMPLIST
:run_step_10
    set _Recent="%NONVOLATILE_DIR%\_Recent"
    set _Desktop="%_Recent%\_Desktop"
    set _RecentFolder="%_Recent%\_RecentFolder"
    set _Start="%_Recent%\_Start"
    set _QuickLaunch="%_Recent%\_QuickLaunch"
    set _net_Recent="%_Recent%\_net_Recent"
    set _Recent_Hash="%_Recent%\Hash"



    echo.
    echo.

:step_10_choice
    set /p userinput="Enter 'f' for forecopy, 'n' for net, 'q' for quit: "

    if /i "%userinput%"=="f" (

        if not exist %_Recent% (
            mkdir %_Recent%
            echo Create Recent Data Directory
            echo [%timestamp%] Create Recent Data Directory >> %_TimeStamp%
        )

        if not exist %_Desktop% (
            mkdir %_Desktop%
            echo Create Desktop Directory
            echo [%timestamp%] Create Desktop Directory >> %_TimeStamp%
        )

        if not exist %_RecentFolder% (
            mkdir %_RecentFolder%
            echo Create RecentFolder Directory 
            echo [%timestamp%] Create RecentFolder Directory >> %_TimeStamp%
        )

        if not exist %_Start% (
            mkdir %_Start%
            echo Create Start Directory 
            echo [%timestamp%] Create Start Directory >> %_TimeStamp%
        )

        if not exist %_QuickLaunch% (
            mkdir %_QuickLaunch%
            echo Create QuickLaunch Directory 
            echo [%timestamp%] Create QuickLaunch Directory >> %_TimeStamp%
        )

        echo You selected forecopy
        forecopy_handy -dr "%USERPROFILE%\Desktop" %_Desktop%
        echo Acquring Desktop Icon...
        echo [%timestamp%] Acquring Desktop Icon... >> %_TimeStamp%

        forecopy_handy -dr "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Recent" %_RecentFolder%
        echo Acquring Recent File...
        echo [%timestamp%] Acquring Recent File... >> %_TimeStamp%  

        forecopy_handy -dr "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" %_Start%
        echo Acquring Start Data...
        echo [%timestamp%] Acquring Start Data... >> %_TimeStamp%

        forecopy_handy -dr "%USERPROFILE%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" %_QuickLaunch%
        echo Acquring QuickLaunch Data...
        echo [%timestamp%] Acquring QuickLaunch Data... >> %_TimeStamp%

        goto step_10_choice

    ) else if /i "%userinput%"=="n" (

        if not exist %_QuickLaunch% (
            mkdir %_net_Recent%
            echo Create _net_Recent Directory 
            echo [%timestamp%] Create _net_Recent Directory >> %_TimeStamp%
        )

        echo You selected net
        if  "%net%"=="4" (
            goto Recent_net4
        ) else if "%net%"=="6" (
            goto Recent_net6
        ) else (
            echo unknown Dot Net Framework version
            goto RUN_STEP_10_Clear
        )

    ) else if /i "%userinput%"=="q" (
        goto RUN_STEP_10_Clear
    ) else (
        echo Invalid input. Please enter 'f', 'n' or 'q'.
        goto step_10_choice
    )

:Recent_net4
    :: Desktop Folder 
    :: C:\Users\<user name>\Desktop
    ::%lecmd% -d %userprofile%\Desktop --csv %_net_Recent%\DesktopFolder --all
    !psexec_opt! -accepteula -i -s cmd.exe /c "%lecmd% -d "%userprofile%\Desktop" --csv %_net_Recent%\DesktopFolder --all & pause"
    :: Recent Folder 
    :: C:\Users<user name>\AppData\Roaming\Microsoft\Windows\Recent
    ::%lecmd% -d %userprofile%\AppData\Roaming\Microsoft\Windows\Recent --csv %_net_Recent%\RecentFolder --all
    !psexec_opt! -accepteula -i -s cmd.exe /c "%lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Recent" --csv %_net_Recent%\RecentFolder --all"
    :: Start Folder 
    :: C:\Users\<user name>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs
    ::%lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" --csv %_net_Recent%\StartFolder --all
    !psexec_opt! -accepteula -i -s cmd.exe /c "%lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" --csv %_net_Recent%\StartFolder --all"
    :: QuickLaunch Folder
    :: C:\Users\<user name>\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch
    ::%lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" --csv %_net_Recent%\QuickLaunch --all
    !psexec_opt! -accepteula -i -s cmd.exe /c "%lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" --csv %_net_Recent%\QuickLaunch --all"

    :: Jump List 
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestination
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent\CustomDestination
    ::%jlecmd% -d %userprofile%\AppData\Roaming\Microsoft\Windows\Recent --csv %_net_Recent%\JumpList --all
    !psexec_opt! -accepteula -i -s cmd.exe /c "%jlecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Recent" --csv %_net_Recent%\JumpList --all"
    echo [%timestamp%] LECmd_net4  >> %_TimeStamp%
    goto step_10_choice

:Recent_net6
    :Recent Files
    ::%lecmd% -d %userprofile%\Desktop --csv %_net_Recent%\DesktopFolder --all
    !psexec_opt! -accepteula -i -s cmd.exe /c "%lecmd% -d "%userprofile%\Desktop" --csv %_net_Recent%\DesktopFolder --all & pause"
    echo [%timestamp%] LECmd Desktop Folder >> %_TimeStamp%
    ::%lecmd% -d %userprofile%\AppData\Roaming\Microsoft\Windows\Recent --csv %_net_Recent%\RecentFolder --all
    !psexec_opt! -accepteula -i -s cmd.exe /c "%lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Recent" --csv %_net_Recent%\RecentFolder --all"
    echo [%timestamp%] LECmd Recent File >> %_TimeStamp%

    ::%lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" --csv %_net_Recent%\StartFolder --all
    !psexec_opt! -accepteula -i -s cmd.exe /c "%lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" --csv %_net_Recent%\StartFolder --all"
    echo [%timestamp%] LECmd Start Folder  >> %_TimeStamp%
    ::%lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" --csv %_net_Recent%\QuickLaunch --all
    !psexec_opt! -accepteula -i -s cmd.exe /c "%lecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" --csv %_net_Recent%\QuickLaunch --all"
    echo [%timestamp%] LECmd Quick Launch >> %_TimeStamp%

    ::Jump List 
    ::%jlecmd% -d %userprofile%\AppData\Roaming\Microsoft\Windows\Recent --csv %_net_Recent%\JumpList --all
    !psexec_opt! -accepteula -i -s cmd.exe /c "%jlecmd% -d "%userprofile%\AppData\Roaming\Microsoft\Windows\Recent" --csv %_net_Recent%\JumpList --all"
    echo [%timestamp%] LECmd Jump List >> %_TimeStamp%
    goto step_10_choice

:RUN_STEP_10_Clear
    ::Hash
    mkdir %_Recent_Hash%
    echo Create Recent Hash Directory 
    echo [%timestamp%] Create Recent Hash Directory >> %_TimeStamp%

    %hashdeep% -e -r %_Recent% > %_Recent_Hash%\_Recent_Hash.txt

    echo RUN_STEP_10 CLEAR
    exit /b

:END_NONVOLATILE_SCRIPT
    echo Terminating the NONVOLATILE data collection script
    echo [%timestamp%] End Time >> %_TimeStamp%
    endlocal
    exit /b