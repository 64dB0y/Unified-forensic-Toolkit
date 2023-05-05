@echo off
setlocal enabledelayedexpansion

echo.
echo **********************************
echo NONVOLATILE DATA
echo **********************************
echo.

:: 초기설정
echo -------------------------------
echo PATH Settings
echo -------------------------------
echo.
SET "ETC=%~dp0etc"
SET "PATH=%ETC%;%PATH%"
SET hashdeep=

echo -----------------Architecture Detection-----------------
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo 64-bit operating system detected.
    set hashdeep=hashdeep64.exe
) else if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    echo 32-bit operating system detected.
    set hashdeep=hashdeep.exe
) else (
    echo Unknown architecture detected.
)
:: 사용 도구 dd, forecopy_handy(v1.2)

set CASE=%1
set NAME=%2

set final_step=10
set choice=


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
echo.

:: LOG TIMESTAMP
set TimeStamp=%foldername%\TimeStamp.log
echo START TIME : %timestamp%
echo [%timestamp%]START TIME >> %TimeStamp%


:: CREATE NONACTIVE DATA DIRECTORY
ECHO CREATE NONVOLATILE DIRECTORY 
SET NONVOLATILE_DIR=%foldername%\NONVOLATILE
MKDIR %NONVOLATILE_DIR%
echo [%timestamp%] CREATE NONVOLATILE DIRECTORY >> %TimeStamp%

:: INPUT CASE, NAME
:INPUT_CASE
echo [%timestamp%]%CASE% >> %TimeStamp%

:INPUT_NAME
echo [%timestamp%]%NAME% >> %TimeStamp%

:Display_Menu
echo.
echo ====================================
echo Select the step you want to perform:
echo ====================================
echo [1] File System MetaData - MFT
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
echo [%timestamp%] Create MBR Directory >> %TimeStamp%

dd if=\\.\PhysicalDrive0 of=%MBR_DIR%\MBR bs=512 count=1
echo [%timestamp%] MBR >> %TimeStamp%

:: MBR HASH 


:: VBR 
:run_step_2
set VBR_DIR=%NONVOLATILE_DIR%\VBR
mkdir %VBR_DIR%
forecopy_handy -f %SystemDrive%\$Boot %VBR_DIR%
echo [%timestamp%] VBR >> %TimeStamp%

:: $MFT
:run_step_3
set MFT_DIR=%NONVOLATILE_DIR%\MFT_DIR
mkdir %MFT_DIR%
forecopy_handy -m %MFT_DIR%
echo [%timestamp%] MFT >> %TimeStamp%

:: $LogFile
:run_step_4
set FileSystemLog=%NONVOLATILE_DIR%\FSLOG
mkdir %FileSystemLog% 
forecopy_handy -f %SystemDrive%\$LogFile %FileSystemLog%
echo [%timestamp%] FILE SYSTEM LOG >> %TimeStamp%

:: REGISTRY
:: -g option : SAM, SYSTEM, SECURITY, SOFTWARE, DEFAULT, NTUSER.DAT 획득 
:run_step_5
set Registry=%NONVOLATILE_DIR%\Registry
mkdir %Registry%
forecopy_handy -g %NONVOLATILE_DIR% %Registry%
echo [%timestamp%] REGISTRY FILE >> %TimeStamp%

:: EVENT LOGS - ok 
:: -e option : Event Log 획득 
:run_step_6
set EventLog=%NONVOLATILE_DIR%\EventLog
mkdir %EventLog%
echo [%timestamp%] Create EventLog Directory >> %TimeStamp%
forecopy_handy -e %NONVOLATILE_DIR% %EventLog%
echo [%timestamp%] EVENT LOG >> %TimeStamp%

:: Prefetch or Superfetch
:run_step_7
set fetch=%NONVOLATILE_DIR%\FetchFile
mkdir %fetch%
echo [%timestamp%] Create Fetch Directory >> %TimeStamp%
forecopy_handy -p %NONVOLATILE_DIR% %fetch%
echo [%timestamp%] PREFATCH OR SUPERFATCH >> %TimeStamp%

:run_step_8
::SET GUID
set guid=
for /f "tokens=3" %%g in ('reg query HKLM\SOFTWARE\Microsoft\Cryptography /v MachineGuid') do (
    set guid=%%g
)
set _restore = %NONVOLATILE_DIR%\Restore
mkdir %_restore%
echo [%timestamp%] Create Restore Directory >> %TimeStamp%
forecopy_handy -r %SYSTEMROOT%\system32\Restore %_restore%
echo [%timestamp%] Restore File >> %TimeStamp%
forecopy_handy -r %HOMEDRIVE%\System Volume Information\_restore{guid} %_restore%


:: SYSTEM32/drivers/etc files
:run_step_9
set Driver=%NONVOLATILE_DIR%\Driver
mkdir %Driver%
echo [%timestamp%] Create Driver Directory >> %TimeStamp%
forecopy_handy -t %Driver%
echo [%timestamp%] Driver Files >> %TimeStamp%

:: RECENT LNKs and JUMPLIST
:run_step_10
set Recent=%NONVOLATILE_DIR%\Recent
mkdir %Recent%
echo [%timestamp%] Create Recent Data Directory >> %TimeStamp%
forecopy_handy -r "%AppData%\microsoft\windows\recent" %Lnk%
echo [%timestamp%] Recent Files >> %TimeStamp%

:: systemprofile (\Windows\system32\config\systemprofile)
forecopy_handy -r "%SystemRoot%\system32\config\systemprofile" %NONVOLATILE_DIR%

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


echo ----------------------
echo End...
echo ----------------------

endlocal
