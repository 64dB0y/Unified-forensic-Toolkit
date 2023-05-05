:: Skelton code

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
SET "PATH=%ETC%;%PATH%

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


:: INPUT CASE, NAME
:INPUT_CASE
echo [%timestamp%]%CASE% >> %TimeStamp%

:INPUT_NAME
echo [%timestamp%]%NAME% >> %TimeStamp%


:: CREATE NONACTIVE DATA DIRECTORY
ECHO CREATE NONVOLATILE DIRECTORY 
SET NONVOLATILE_DIR=%foldername%\NONVOLATILE
MKDIR %NONVOLATILE_DIR%
echo [%timestamp%] CREATE NONVOLATILE DIRECTORY >> %TimeStamp%

:: MBR
set MBR_DIR=%NONVOLATILE_DIR%\MBR
mkdir %MBR_DIR%
dd if=\\.\PhysicalDrive0 of=%MBR_DIR%\MBR bs=512 count=1
echo [%timestamp%] MBR >> %TimeStamp%

:: VBR 
set VBR_DIR=%NONVOLATILE_DIR%\VBR
mkdir %VBR_DIR%
forecopy_handy -f %SystemDrive%\$Boot %VBR_DIR%
echo [%timestamp%] VBR >> %TimeStamp%

:: $MFT
set MFT_DIR=%NONVOLATILE_DIR%\MFT_DIR
mkdir %MFT_DIR%
forecopy_handy -m %MFT_DIR%
echo [%timestamp%] MFT >> %TimeStamp%

:: $LogFile
set FileSystemLog=%NONVOLATILE_DIR%\FSLOG
mkdir %FileSystemLog% 
forecopy_handy -f %SystemDrive%\$LogFile %FileSystemLog%
echo [%timestamp%] FILE SYSTEM LOG >> %TimeStamp%

:: REGISTRY
:: -g option : SAM, SYSTEM, SECURITY, SOFTWARE, DEFAULT, NTUSER.DAT 획득 
forecopy_handy -g %NONVOLATILE_DIR%
echo [%timestamp%] REGISTRY FILE >> %TimeStamp%

:: EVENT LOGS - ok 
:: -e option : Event Log 획득 
forecopy_handy -e %NONVOLATILE_DIR%
echo [%timestamp%] EVENT LOG >> %TimeStamp%

:: Prefatch or Superfatch
forecopy_handy -p %NONVOLATILE_DIR%
echo [%timestamp%] PREFATCH OR SUPERFATCH >> %TimeStamp%

:: RECENT LNKs and JUMPLIST
forecopy_handy -r "%AppData%\microsoft\windows\recent" %NONVOLATILE_DIR%

:: SYSTEM32/drivers/etc files
forecopy_handy -t %NONVOLATILE_DIR%
	
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
