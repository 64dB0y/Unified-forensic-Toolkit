@echo off
setlocal enabledelayedexpansion

REM PATH Settings 사용 도구 dd, forecopy_handy(v1.2)

SET "curDir=%~dp0"
SET "ETC=%~dp0etc"
SET "HASH=%~dp0HASH"
SET "PATH=%curDir%;%ETC%;%HASH%;%PATH%"

echo **********************************
echo NONVOLATILE DATA
echo **********************************
echo.
set CASE=%1
set NAME=%2

set final_step=10
set choice=

:: Check .NET Framework4 or 6
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" >nul 2>&1
if %errorlevel%==0 (
    echo .NET Framework version 4 is installed. >>%curDir%\basic_info.txt
    set "net=4"
    set "rbcmd=%curDir%\net4\RBCMD\RBCmd.exe"
    set "lecmd=%curDir%\net4\LECmd\LECmd.exe"
    set "jlecmd=%curDir%\net4\JLECmd\JLECmd.exe"
    set "pecmd=%curDir%\net4\PECmd\PECmd.exe"
    set "evtxecmd=%curDir%\net4\EvtxeCmd\EvtxECmd.exe"
    goto Check_Architecture
)

reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v6.0" >nul 2>&1
if %errorlevel%==0 (
    echo .NET Framework version 6 is installed. >> %curDir%\basic_info.txt
    set "net=6"
    set "rbcmd=%curDir%\net6\RBCmd\RBCmd.exe"
    set "lecmd=%curDir%\net6\LECmd\LECmd.exe"
    set "jlecmd=%curDir%\net6\JLECmd\JLECmd.exe"
    set "pecmd=%curDir%\net6\PECmd\PECmd.exe"
    set "evtxecmd=%curDir%\net6\EvtxeCmd\EvtxECmd.exe"
    goto Check_Architecture
)

echo .NET Framework is not installed. >> %curDir%\basic_info.txt
goto Check_Architecture


:Check_Architecture
    :: -----------------Architecture Detection-----------------
    if %PROCESSOR_ARCHITECTURE%==AMD64 (
        echo 64-bit operating system detected. >> %curDir%\basic_info.txt
        set "hashdeep=%HASH%\hashdeep64.exe"
    ) else if %PROCESSOR_ARCHITECTURE%==x86 (
        echo 32-bit operating system detected. >> %curDir%\basic_info.txt
        set "hashdeep=%HASH%\hashdeep.exe"
    ) else (
        echo Unknown archtecture detected. >> %curDir%\basic_info.txt
    )


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

:Menu
    echo.
    echo ====================================
    echo Select the step you want to perform:
    echo ====================================
    echo [1] File System MetaData - MFT or FAT  
    echo [2] Registry File - SAM, SYSTEM, SOFTWARE, SECURITY
    echo [3] Prefetch File
    echo [4] Event Log File
    echo [5] Recycle Bin Information 
    echo [6] Browser history
    echo [7] Temporary Files
    echo [8] System Restore Point
    echo [9] Portable System History
    echo [10] Link File
    echo [a] RUN ALL STEPS
    echo [q] QUIT
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
    goto :Menu

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

    echo.
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
    forecopy_handy -dr %SystemDrive%\$Recycle.Bin %recycleBin% 2>> Error.log

    echo.
    echo Acquring RecycleBin 
    echo [%timestamp%] Acquring RecycleBin >> %_TimeStamp%

    :: Hash
    set recycleBinHash=%recycleBin%\_Hash
    mkdir %recycleBinHash%
    echo [%timestamp%] Create RecycleBin Hash Directory >> %_TimeStamp%
    echo.
    %hashdeep% -e -r %recycleBin%\$Recycle.Bin > %recycleBinHash%\_RecycleBin_Hash.txt
    echo.
    echo Calculate RecycleBin Hash...
    echo [%timestamp%] Calculate RecycleBin Hash... >> %_TimeStamp%
    if "%net%"=="4" (
        goto RecycleBin_net4
    ) else if "%net%"=="6" (
        goto RecycleBin_net6
    ) else (
        goto RUN_STEP_5_Clear
    )

:RecycleBin_net4
    %rbcmd% -d "%SystemDrive%\$Recycle.Bin" --csv %recycleBin% --csvf RecycleBin.csv
    goto RUN_STEP_5_Clear
:RecycleBin_net6
    %rbcmd% -d "%SystemDrive%\$Recycle.Bin" --csv %recycleBin% --csvf RecycleBin.csv
    goto RUN_STEP_5_Clear
:RUN_STEP_5_Clear
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
    forecopy_handy -f "%LocalAppData%\Google\Chrome\User Data\Default\History" %_Chrome%
    forecopy_handy -dr "%LocalAppData%\Google\Chrome\User Data\Default\Download Service" %_Chrome%
    forecopy_handy -dr "%LocalAppData%\Google\Chrome\User Data\Default\Network" %_Chrome%

    :: Naver Whale
    echo Acquring Whale Data...
    echo [%timestamp%] Acquring Whale Data... >> %_TimeStamp%

    forecopy_handy -dr "%LocalAppData%\Naver\Naver Whale\User Data\Default\Cache" %_Whale% 2>> Error.log
    forecopy_handy -dr "%LocalAppData%\Naver\Naver Whale\User Data\Default\Download Service" %_Whale% 2>> Error.log
    forecopy_handy -dr "%LocalAppData%\Naver\Naver Whale\User Data\Default\Network" %_Whale% 2>> Error.log
    forecopy_handy -f "%LocalAppData%\Naver\Naver Whale\User Data\Default\History" %_Whale% 2>> Error.log

    :: Edge
    echo Acuqring Edge Data...
    echo [%timestamp%] Acquring Edge Data... >> %_TimeStamp%
    forecopy_handy -dr "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache" %_Edge% 
    forecopy_handy -dr "%LocalAppData%\Microsoft\Edge\User Data\Default\Download Service" %_Edge%
    forecopy_handy -dr "%LocalAppData%\Microsoft\Edge\User Data\Default\Network" %_Edge%
    forecopy_handy -f "%LocalAppData%\Microsoft\Edge\User Data\Default\History" %_Edge%

    :: Firefox
    echo Acquring Firefox Data...
    echo [%timestamp%] Acquring Firefox Data... >> %_TimeStamp%
    forecopy_handy -x %_Firefox%

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
    %hashdeep% -e -r %_Firefox% > %_Firefox_Hash%\Firefox_Hash.txt 2>> Error.log


    mkdir %_Edge_Hash%
    echo [%timestamp%] Create Edge Hash Directory >> %_TimeStamp%
    echo Calculate Edge Hash
    echo [%timestamp%] Calculate Edge Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Edge% > %_Edge_Hash%\Edge_Hash.txt 

    
    mkdir %_Whale_Hash%
    echo [%timestamp%] Create Whale Hash Directory >> %_TimeStamp%
    echo Calculate Whale Hash
    echo [%timestamp%] Calculate Whale Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Whale% > %_Whale_Hash%\Whale_Hash.txt 2>> Error.log

    mkdir %_WebCache_Hash%
    echo [%timestamp%] Create WebCache Hash Directory >> %_TimeStamp%
    echo Calcultae WebCache Hash
    echo [%timestamp%] Calculate WebCache Hash >> %_TimeStamp%
    %hashdeep% %_WebCache% > %_WebCache_Hash%\WebCache_Hash.txt

    echo RUN_STEP_6_CLEAR
    echo [%timestamp%] RUN_STEP_6_CLEAR >> %_TimeStamp%
    exit /b


:: IconCache
:: set ICONCACHE=%NONVOLATILE_DIR%\iconcache
:: mkdir %ICONCACHE%
::forecopy_handy -f %LocalAppData%\IconCache.db %ICONCACHE%	
	
:: Thumbcnale ache
::forecopy_handy -r "%LocalAppData%\microsoft\windows\explorer" %NONVOLATILE_DIR%	
	
:: Downloaded Program Files
::forecopy_handy -r "%SystemRoot%\Downloaded Program Files" %NONVOLATILE_DIR%	
	
:: Java IDX cache
::forecopy_handy -r "%UserProfile%\AppData\LocalLow\Sun\Java\Deployment" %NONVOLATILE_DIR%	
	
:: WER (Windows Error Reporting)
::forecopy_handy -r "%LocalAppData%\Microsoft\Windows\WER" %NONVOLATILE_DIR%
	
:: Windows Timeline
::forecopy_handy -r "%LocalAppData%\ConnectedDevicesPlatform" %NONVOLATILE_DIR%
	
:: Windows Search Database
::forecopy_handy -r "%ProgramData%\Microsoft\Search\Data\Applications\Windows" %NONVOLATILE_DIR%


:: 임시파일 
:run_step_7
    :: $UsnJrnl$J
    :: $LogFile
    set _TempFile=%NONVOLATILE_DIR%\_Temp
    mkdir %_TempFile%
    echo Create Temp Directory 
    echo [%timestamp%] Create Temp Directory  >> %_TimeStamp%
    forecopy_handy -dr %temp% %_TempFile%
    echo Acquring Temp Data...
    echo [%timestamp%] Acquring Temp Data... >> %_TimeStamp%

    set _TempFile_Hash=%_TempFile%\_Hash
    mkdir %_TempFile_Hash%
    echo Create TempFile Hash Direcotry
    echo [%timestamp%] Create TempFile Hash Direcotry >> %_TimeStamp%
    %hashdeep% -e -r %_TempFile% > %_TempFile_Hash%\_Temp_Hash.txt
    echo Calculate Temp Hash >> %_TimeStamp%
    echo [%timestamp%] Calculate Temp Hash >> %_TimeStamp%

    echo RUN_STEP_7 CLEAR
    echo [%timestamp%] RUN_STEP_7 CLEAR >> %_TimeStamp%
    exit /b
    
:run_step_8
::SET GUID
set guid=
for /f "tokens=3" %%g in ('reg query HKLM\SOFTWARE\Microsoft\Cryptography /v MachineGuid') do (
    set guid=%%g
)
set _restore=%NONVOLATILE_DIR%\Restore
mkdir %_restore%
echo [%timestamp%] Create Restore Directory >> %_TimeStamp%
forecopy_handy -r %SYSTEMROOT%\system32\Restore %_restore%
echo [%timestamp%] Restore Dump created >> %_TimeStamp%
forecopy_handy -r "%HOMEDRIVE%\System Volume Information\_restore{%guid%}" %_restore%
echo [%timestamp%] System Volume Information Dump created >> %_TimeStamp%

set _restore_HASH=%NONVOLATILE_DIR%\Restore\HASH
mkdir %_restore_HASH%
%hashdeep% -r %_restore% > "%_restore_HASH%\_restore_HASH.txt"
echo [%timestamp%] Create HASH FILE FOR All Restore File >> %_TimeStamp%

:run_step_9
:: SYSTEM32/drivers/etc files
set Driver=%NONVOLATILE_DIR%\Driver
mkdir %Driver%
echo [%timestamp%] Create Driver Directory >> %_TimeStamp%
forecopy_handy -t %Driver%
echo [%timestamp%] Driver Files >> %_TimeStamp%

:: Create HASH
set Driver_HASH=%Driver%\HASH
mkdir %Driver_HASH%
echo [%timestamp%] Created HASH Directory >> %TimeStamp%
%hashdeep% -r %Driver% > "%Driver_HASH%\Driver_hash.txt"
echo [%timestamp%] Created Driver HASH >> %TimeStamp%


:: RECENT LNKs and JUMPLIST
:run_step_10
set Recent=%NONVOLATILE_DIR%\Recent
:: Create Recent Directory
mkdir %Recent%
echo [%timestamp%] Create Recent Data Directory >> %_TimeStamp%

:: Recent File
mkdir %Recent%\Recent_Files
echo [%timestamp%] Create Recent_Files Directory >> %_TimeStamp%
forecopy_handy -r "%AppData%\microsoft\windows\recent" %Recent%\Recent_Files
echo [%timestamp%] Recent File Dump Created >> %_TimeStamp%

:: systemprofile (\Windows\system32\config\systemprofile)
mkdir %Recent%\systemprofile
echo [%timestamp%] Create systemprofile Directory >> %_TimeStamp%
forecopy_handy -r "%SystemRoot%\system32\config\systemprofile" %Recent%\systemprofile
echo [%timestamp%] systemprofile Dump Created >> %_TimeStamp%

:: Create HASH
set Recent_HASH=%Recent%\HASH
mkdir %Recent_HASH%
echo [%timestamp%] Created HASH Directory >> %TimeStamp%

:: Recent File Hash
%hashdeep% -r "%Recent%\Recent_Files" > "%Recent_HASH%\Recent_hash.txt"
echo [%timestamp%] Created Recent files HASH >> %TimeStamp%

:: SystemProfile Hahs
%hashdeep% -r "%Recent%\systemprofile" > "%Recent_HASH%\systemprofile_hash.txt"
echo [%timestamp%] Created systemprofile files HASH >> %TimeStamp%



echo ----------------------
echo End...
echo ----------------------

endlocal