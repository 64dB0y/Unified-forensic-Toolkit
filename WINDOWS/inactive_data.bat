@echo off
setlocal enabledelayedexpansion

echo.
echo **********************************
echo NONVOLATILE DATA
echo **********************************
echo.

:: 초기설정
:: -------------------------------
:: PATH Settings
:: -------------------------------
:: 사용 도구 dd, forecopy_handy(v1.2)
set CASE=%1
set NAME=%2

set final_step=10
set choice=

SET "curDir=%~dp0"
SET "ETC=%~dp0etc"
SET "HASH=%~dp0HASH"
SET "PATH=%ETC%;%HASH%;%PATH%"
echo %curDir%

:: Check .NET Framework4 or 6
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" >nul 2>&1
if %errorlevel%==0 (
    echo .NET Framework version 4 is installed. >>%curDir%\basic_info.txt
    set "net=4"
    set "rbcmd=%curDir%\net4\RBCmd.exe"
    goto Check_Architecture
)

reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v6.0" >nul 2>&1
if %errorlevel%==0 (
    echo .NET Framework version 6 is installed. >> %curDir%\basic_info.txt
    set "net=6"
    set "rbcmd=%curDir%\net6\RBCmd.exe"
    echo %rbcmd%
    goto Check_Architecture
)

echo .NET Framework is not installed. >> %curDir%\basic_info.txt
goto Check_Architecture


:Check_Architecture
:: -----------------Architecture Detection-----------------
if %PROCESSOR_ARCHITECTURE%==AMD64 (
    echo 64-bit operating system detected. >> %curDir%\basic_info.txt
    set hashdeep=%HASH%\hashdeep64.exe
) else if %PROCESSOR_ARCHITECTURE%==x86 (
    echo 32-bit operating system detected. >> %curDir%\basic_info.txt
    set hashdeep=%HASH%\hashdeep.exe
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

:: CREATE NONACTIVE DATA DIRECTORY
set NONVOLATILE_DIR=%foldername%\NONVOLATILE
mkdir %NONVOLATILE_DIR%
echo [%timestamp%] CREATE NONVOLATILE DIRECTORY >> %_TimeStamp%

:: INPUT CASE, NAME
:INPUT_CASE
echo [%timestamp%]%CASE% >> %_TimeStamp%

:INPUT_NAME
echo [%timestamp%]%NAME% >> %_TimeStamp%

:Display_Menu
echo.
echo ====================================
echo Select the step you want to perform:
echo ====================================
echo [1] File System MetaData - MFT, VBR, MBR
echo [2] Registry File - SAM, SYSTEM, SOFTWARE, SECURITY
echo [3] Prefetch OR SuperFetch
echo [4] Log Files - *.evt Files
echo [5] Recycle Bin Files
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
goto :Display_Menu

:: MBR
:run_step_1
set MBR_DIR=%NONVOLATILE_DIR%\MBR
mkdir %MBR_DIR%
echo [%timestamp%] Create MBR Directory >> %_TimeStamp%
dd if=\\.\PhysicalDrive0 of=%MBR_DIR%\MBR bs=512 count=1
echo [%timestamp%] MBR >> %_TimeStamp%

:: MBR HASH 
set MBR_HASH=%MBR_DIR%\HASH
mkdir %MBR_HASH%
echo [%timestamp%] CREATE MBR HASH Directory >> %_TimeStamp%
%hashdeep% -e "%MBR_DIR%\MBR" > "%MBR_HASH%\MBR_HASH.txt"
echo [%timestamp%] MBR HASH >> %_TimeStamp%

::VBR
set VBR_DIR=%NONVOLATILE_DIR%\VBR
mkdir %VBR_DIR%
forecopy_handy -f %SystemDrive%\$Boot %VBR_DIR%
echo [%timestamp%] VBR >> %_TimeStamp%

:: VBR HASH 
set VBR_HASH=%VBR_DIR%\HASH
mkdir %VBR_HASH%
echo [%timestamp%] CREATE VBR HASH Directory >> %_TimeStamp%
%hashdeep% -e "%VBR_DIR%\$Boot" > "%VBR_HASH%\BOOT_HASH.txt"
echo [%timestamp%] VBR HASH >> %_TimeStamp%

set MFT_DIR=%NONVOLATILE_DIR%\MFT
mkdir %MFT_DIR%
forecopy_handy -m %MFT_DIR%
echo [%timestamp%] MFT >> %_TimeStamp%

:: MFT HASH
set MFT_HASH=%MFT_DIR%\HASH
mkdir %MFT_HASH%
echo [%timestamp%] CREATE MFT HASH Directory >> %_TimeStamp%
%hashdeep% -e "%MFT_DIR%\mft\$MFT" > "%MFT_HASH%\MFT_HASH.txt"
echo [%timestamp%] MFT HASH >> %_TimeStamp%

echo Step completed: %choice%
exit /b

:: REGISTRY
:: -g option : SAM, SYSTEM, SECURITY, SOFTWARE, DEFAULT, NTUSER.DAT 획득 
:run_step_2
set Registry=%NONVOLATILE_DIR%\Registry
mkdir %Registry%
forecopy_handy -g %Registry%
echo [%timestamp%] REGISTRY >> %_TimeStamp%

:: HASH
set REGISTRY_HASH=%Registry%\Hash
mkdir %REGISTRY_HASH%
echo [%timestamp%] Create Registry Hash Directory >> %_TimeStamp%
%hashdeep% -e -r %Registry%\registry  > %REGISTRY_HASH%\REGISTRY_HASH.txt
echo [%timestamp%] REGISTRY FILE HASH >> %_TimeStamp%

echo Step completed: %choice%
exit /b

:: PreFetch OR SuperFetch
:run_step_3
set fetch=%NONVOLATILE_DIR%\FetchFile
mkdir %fetch%
echo [%timestamp%] Create Fetch Directory >> %_TimeStamp%
forecopy_handy -p  %fetch%
echo [%timestamp%] Fetch File >> %_TimeStamp%

:: HASH
set fetchHash=%fetch%\Hash
mkdir %fetchHash%
echo [%timestamp%] Create Fetch Hash Directory >> %_TimeStamp%
%hashdeep% -e -r %fetch%\prefetch > %fetchHash%\fetchHash.txt
echo [%timestamp%] Fetch File Hash >> %_TimeStamp%

echo Step completed: %choice%
exit /b

:: $LogFile
:run_step_4
:: -e option : Event Log 획득 
set eventLog=%NONVOLATILE_DIR%\EventLog
mkdir %eventLog%
echo [%timestamp%] Create EventLog Directory >> %_TimeStamp%
forecopy_handy -e  %eventLog%
echo [%timestamp%] EVENT LOG >> %_TimeStamp%

set eventHash=%eventLog%\Hash
mkdir %eventHash%
echo [%timestamp%] Create EventLog Hash Directory >> %_TimeStamp%
%hashdeep% -e -r %eventLog%\eventlogs\Logs > %eventHash%\eventHash.txt

echo Step completed: %choice%
exit /b

:run_step_5
set recycleBin=%NONVOLATILE_DIR%\recycleBin
mkdir %recycleBin%
echo [%timestamp%] Create RecycleBin Directory >> %_TimeStamp%

if  "%net%"=="4" (
    goto RecycleBin_net4
) else if "%net%"=="6" (
    goto RecycleBin_net6
) else (
    goto RecycleBin_fore
)

:RecycleBin_net4
echo now execute net4
%rbcmd% -d %SystemDrive%\$Recycle.bin --csv %recycleBin%
echo [%timestamp%] Recycle Bin Data >> %_TimeStamp%
exit /b

:RecycleBin_net6
echo now execute net6
%rbcmd% -d %SystemDrive%\$Recycle.bin --csv %recycleBin%
echo [%timestamp%] Recycle Bin Data >> %_TimeStamp%
exit /b

:RecycleBin_fore
echo now execute fore
forecopy_handy -r %SystemDrive%\$Recycle.Bin %recycleBin%
echo [%timestamp%] Recycle Bin Data >> %_TimeStamp%
exit /b




:run_step_6
::브라우저 사용 흔적
:: IE Artifacts
forecopy_handy -i %NONVOLATILE_DIR%
	
:: Firefox Artifacts
forecopy_handy -x %NONVOLATILE_DIR%	

:: Chrome Artifacts
forecopy_handy -c %NONVOLATILE_DIR%

:: IconCache
set ICONCACHE=%NONVOLATILE_DIR%\iconcache
mkdir %ICONCACHE%

forecopy_handy -f %LocalAppData%\IconCache.db %ICONCACHE%	
	
:: Thumbcache
forecopy_handy -r "%LocalAppData%\microsoft\windows\explorer" %NONVOLATILE_DIR%	
	
:: Downloaded Program Files
forecopy_handy -r "%SystemRoot%\Downloaded Program Files" %NONVOLATILE_DIR%	
	
:: Java IDX cache
forecopy_handy -r "%UserProfile%\AppData\LocalLow\Sun\Java\Deployment" %NONVOLATILE_DIR%	
	
:: WER (Windows Error Reporting)
forecopy_handy -r "%LocalAppData%\Microsoft\Windows\WER" %NONVOLATILE_DIR%
	
:: Windows Timeline
forecopy_handy -r "%LocalAppData%\ConnectedDevicesPlatform" %NONVOLATILE_DIR%
	
:: Windows Search Database
forecopy_handy -r "%ProgramData%\Microsoft\Search\Data\Applications\Windows" %NONVOLATILE_DIR%

:: 임시파일 
:run_step_7
set FileSystemLog=%NONVOLATILE_DIR%\FSLOG
mkdir %FileSystemLog% 
echo [%timestamp%] Create FILE SYSTEM LOG Directory >> %_TimeStamp%
forecopy_handy -f %SystemDrive%\$LogFile %FileSystemLog%
echo [%timestamp%] FILE SYSTEM LOG >> %_TimeStamp%

:: FSLOG HASH
set FSLOG_HASH=%FileSystemLog%\HASH
mkdir FSLOG_HASH
echo [%timestamp%] Create File System Log Hash >> %_TimeStamp%
%hashdeep% "%FileSystemLog%\$LogFile" > "%FSLOG_HASH%\FSLOG_HASH.txt"
echo [%timestamp%] FILE SYSTEM LOG HASH >> %_TimeStamp%


:run_step_8
::SET GUID
set guid=
for /f "tokens=3" %%g in ('reg query HKLM\SOFTWARE\Microsoft\Cryptography /v MachineGuid') do (
    set guid=%%g
)
set _restore = %NONVOLATILE_DIR%\Restore
mkdir %_restore%
echo [%timestamp%] Create Restore Directory >> %Tim_TimeStampeStamp%
forecopy_handy -r %SYSTEMROOT%\system32\Restore %_restore%
echo [%timestamp%] Restore File >> %_TimeStamp%
forecopy_handy -r %HOMEDRIVE%\System Volume Information\_restore{guid} %_restore%


:: SYSTEM32/drivers/etc files
:run_step_9
set Driver=%NONVOLATILE_DIR%\Driver
mkdir %Driver%
echo [%timestamp%] Create Driver Directory >> %_TimeStamp%
forecopy_handy -t %Driver%
echo [%timestamp%] Driver Files >> %_TimeStamp%


:: RECENT LNKs and JUMPLIST
:run_step_10
set Recent=%NONVOLATILE_DIR%\Recent
mkdir %Recent%
echo [%timestamp%] Create Recent Data Directory >> %_TimeStamp%
forecopy_handy -r "%AppData%\microsoft\windows\recent" %Lnk%
echo [%timestamp%] Recent Files >> %_TimeStamp%

:: systemprofile (\Windows\system32\config\systemprofile)
forecopy_handy -r "%SystemRoot%\system32\config\systemprofile" %NONVOLATILE_DIR%



echo ----------------------
echo End...
echo ----------------------

endlocal
