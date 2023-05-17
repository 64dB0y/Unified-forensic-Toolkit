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
set foldername=%3%computername%_%timestamp%
mkdir "%foldername%"
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
        goto :Menu
    ) else (
        set "steps="
        for %%x in (%choice%) do (
            if /i "%%x"=="q" (
                IF EXIST forecopy_handy.log (
                    move forecopy_handy.log %NONVOLATILE_DIR%\
                )
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
        call :run_step_%%x
        )
    )
    goto :Menu


:: MFT
:: OK
:run_step_1
    set _FileSystem=%NONVOLATILE_DIR%\_FileSystem
    mkdir %_FileSystem% 
    echo [%timestamp%] Create FileSystem Data Directory >> %_TimeStamp%

    %kape%\kape.exe --tsource %SystemDrive% --target FileSystem --tdest %_FileSystem% --tflush
    if "%net%"=="4" (
        goto MFTParser_net4
    ) else if "%net%"=="6" (
        goto MFTParser_net6
    ) else (
        goto RUN_STEP_1_Clear
    )

:MFTParser_net4
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$MFT --csv %_FileSystem% --csvf "mft_parser.csv"
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Boot --csv %_FileSystem% --csvf "Boot_parser.csv"
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Extend\$J --csv %_FileSystem% --csvf "Extend_parser.csv"
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Secure_$SDS --csv %_FileSystem% --csvf "SDS_parser.csv"
    goto RUN_STEP_1_Clear

:MFTParser_net6
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$MFT --csv %_FileSystem% --csvf "mft_parser.csv"
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Boot --csv %_FileSystem% --csvf "Boot_parser.csv"
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Extend\$J --csv %_FileSystem% --csvf "Extend_parser.csv"
    %mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Secure_$SDS --csv %_FileSystem% --csvf "SDS_parser.csv"
    goto RUN_STEP_1_Clear

:RUN_STEP_1_Clear
    echo RUN_STEP_1 CLEAR
    exit /b

:run_step_2
    set Registry=%NONVOLATILE_DIR%\_Registry
    mkdir %Registry%
    echo [%timestamp%] Create Registry Directory >> %_TimeStamp%
    forecopy_handy -g %Registry%
    echo Acquring Registry...
    echo [%timestamp%] Acquring Registry >> %_TimeStamp%

    set REGISTRY_HASH=%Registry%\_Hash
    mkdir %REGISTRY_HASH%
    echo [%timestamp%] Create Registry Hash Directory >> %_TimeStamp%
    %hashdeep% -e -r %Registry%\registry  > %REGISTRY_HASH%\_REGISTRY_Hash.txt  
    echo Calculate Registry Hash...
    echo [%timestamp%] Calculate Registry Hash... >> %_TimeStamp%

    echo RUN_STEP_2 CLEAR
    exit /b

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
::  소프트웨어를 비롯해서 사용자의 어플리케이션의 이벤트를 기록
::  C:\Windows\System32\winevt\Logs\Security.evtx 
::  보안 관련된 이벤트 로그, Windows 로그온, 네트워크 등 다양한 로그 기록
::  C:\Windows\System32\winevt\Logs\System.evtx
::  서비스 실행 여부나 파일 시스템, 디바이스 오류 등의 정보 기록
::  C:\Windows\System32\winevt\Logs\Setup.evtx
::  어플리케이션 설치 시 발생하는 이벤트를 기록하고 프로그램이 잘 설치되었는지, 호환성 관련 정보 기록

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
        %rbcmd% -d "%SystemDrive%\$Recycle.Bin" --csv %recycleBin% --csvf RecycleBin.csv
        echo [%timestamp%] rbcmd for net4 completed(Step5) >> %_TimeStamp%
        GOTO input_prompt

    :RecycleBin_net6
        echo rbcmd for net6 executed(Step5)
        %rbcmd% -d "%SystemDrive%\$Recycle.Bin" --csv %recycleBin% --csvf RecycleBin.csv
        echo [%timestamp%] rbcmd for net6 completed(Step5) >> %_TimeStamp%
        GOTO input_prompt

    :XCopyCommand
        echo xcopy executed(Step5)
        xcopy /e /h /y %SystemDrive%\$Recycle.Bin %recycleBin% 2>> %recycleBin%\recycleBin_collect_Error.log
        echo [%timestamp%] xcopy completed(Step5) >> %_TimeStamp%
        GOTO input_prompt

    :kape
        echo kape executed(Step5)
        %kape%\kape.exe --tsource %systemdrive% --target RecycleBin --tdest %kapedir%
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
::SET GUID
::    set guid=
::    for /f "tokens=3" %%g in ('reg query HKLM\SOFTWARE\Microsoft\Cryptography /v MachineGuid') do (
::        set guid=%%g
::    )
    set _restore=%NONVOLATILE_DIR%\_Restore
    mkdir %_restore%
    echo [%timestamp%] Create Restore Directory >> %_TimeStamp%
    ::forecopy_handy -dr %SYSTEMROOT%\system32\Restore %_restore%
    xcopy /E /H /I "%SYSTEMROOT%\system32\Restore" "%_restore%"
    echo [%timestamp%] Restore File >> %_TimeStamp%
    ::forecopy_handy -dr %HOMEDRIVE%\System Volume Information\_restore{guid} %_restore%

    echo RUN_STEP_7 CLEAR
    exit /b

:run_step_8
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

    echo RUN_STEP_8 CLEAR
    exit /b
:: SYSTEM32/drivers/etc files
:run_step_9
set _Recent=%NONVOLATILE_DIR%\_Recent  
    mkdir %_Recent%
    echo Create Recent Data Directory 
    echo [%timestamp%] Create Recent Data Directory >> %_TimeStamp%

    set _Desktop=%_Recent%\_Desktop
    mkdir %_Desktop%
    echo Create Desktop Directory 
    echo [%timestamp%] Create Desktop Directory >> %_TimeStamp%
    
    :: ok
    forecopy_handy -r %USERPROFILE%\Desktop %_Desktop%
    echo Acquring Desktop Icon...
    echo [%timestamp%] Acquring Desktop Icon... >> %_TimeStamp%

    set _Recent_File=%_Recent%/_Recent_File
    mkdir %_Recent_File%
    echo Create Recent File Directory 
    echo [%timestamp%] Create Recent File Directory >> %_TimeStamp%
    
    :: ok 
    forecopy_handy -r "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Recent" %_Recent_File%
    echo Acquring Recent File...
    echo [%timestamp%] Acquring Recent File... >> %_TimeStamp%  

    set _Start=%_Recent%\_Start    
    mkdir %_Start%
    echo Create Start Directory 
    echo [%timestamp%] Create Start Directory >> %_TimeStamp%
    
    :: ok
    forecopy_handy -r "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" %_Start%
    echo Acquring Start Data...
    echo [%timestamp%] Acquring Start Data... >> %_TimeStamp%

    set _QuickLaunch=%_Recent%\_QuickLaunch    
    mkdir %_QuickLaunch%
    echo Create QuickLaunch Directory 
    echo [%timestamp%] Create QuickLaunch Directory >> %_TimeStamp%

    forecopy_handy -r "%USERPROFILE%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" %_QuickLaunch%
    echo Acquring QuickLaunch Data...
    echo [%timestamp%] Acquring QuickLaunch Data... >> %_TimeStamp%

    ::Hash
    set _Recent_Hash=%_Recent%\Hash
    mkdir %_Recent_Hash%
    echo Create Recent Hash Directory 
    echo [%timestamp%] Create Recent Hash Directory >> %_TimeStamp%

    %hashdeep% -e -r %_Recent% > %_Recent_Hash%\_Recent_Hash.txt
    ::set _SystemProfile=%NONVOLATILE_DIR%\_SystemProfile
    ::mkdir %_SystemProfile%
    ::echo Create System Profile Directory >> %_TimeStamp%
    ::echo [%timestamp%] Create System Profile Directory >> %_TimeStamp%

    :: systemprofile (\Windows\system32\config\systemprofile)
    ::forecopy_handy -dr "%SystemRoot%\system32\config\systemprofile" %NONVOLATILE_DIR%

    ::echo Acquring System Profile... >> %_TimeStamp%
    ::echo [%timestamp%] Acquring System Profile... >> %_TimeStamp%

    if  "%net%"=="4" (
        goto Recent_net4
    ) else if "%net%"=="6" (
        goto Recent_net6
    ) else (
        goto RUN_STEP_9_Clear
    )

:Recent_net4
    :: Desktop Folder 
    :: C:\Users\<user name>\Desktop
    %lecmd% -d %userprofile%\Desktop --csv %_Desktop% --all
    :: Recent Folder 
    :: C:\Users<user name>\AppData\Roaming\Microsoft\Windows\Recent
    %lecmd% -d %userprofile%\AppData\Roaming\Microsfot\Windows\Recent --csv %_Recent_File% --all
    :: Start Folder 
    :: C:\Users\<user name>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs
    %lecmd% -d %userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs --csv %_Start% --all
    :: QuickLaunch Folder
    :: C:\Users\<user name>\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch
    %lecmd% -d %userprofile%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch --csv %_QuickLaunch% --all

    :: Jump List 
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestination
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent\CustomDestination
    %jlecmd% -d %userprofile%\AppData\Roaming\Microsoft\Windows\Recent --csv %_Recent% --all
    echo [%timestamp%] LECmd_net4  >> %_TimeStamp%
    goto RUN_STEP_10_Clear

:Recent_net6
    :: Desktop Folder 
    :: C:\Users\<user name>\Desktop
    %lecmd% -d %userprofile%\Desktop --csv %_Desktop% --all
    :: Recent Folder 
    :: C:\Users<user name>\AppData\Roaming\Microsoft\Windows\Recent
    %lecmd% -d %userprofile%\AppData\Roaming\Microsfot\Windows\Recent --csv %_Recent_File% --all
    :: Start Folder 
    :: C:\Users\<user name>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs
    %lecmd% -d %userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs --csv %_Start% --all
    :: QuickLaunch Folder
    :: C:\Users\<user name>\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch
    %lecmd% -d %userprofile%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch --csv %_QuickLaunch% --all

    :: Jump List 
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestination
    :: C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent\CustomDestination
    %jlecmd% -d %userprofile%\AppData\Roaming\Microsoft\Windows\Recent --csv %_Recent% --all
    echo [%timestamp%] LECmd_net4  >> %_TimeStamp%
    goto RUN_STEP_9_Clear

:RUN_STEP_9_Clear
    echo RUN_STEP_9 CLEAR
    exit /b


echo [%timestamp%] End Time >> %_TimeStamp%
endlocal
:: RECENT LNKs and JUMPLIST
