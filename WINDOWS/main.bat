@echo off
setlocal enabledelayedexpansion

cls
::chcp 65001 > nul
set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%
set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
set minute=%time:~3,2%
set second=%time:~6,2%
set timestamp=%year%-%month%-%day%_%hour%-%minute%-%second%
set CASE=""
set NAME=""

:: -----------------------------------------------------
:: Enter the case name
:: -----------------------------------------------------
:ENTER_CASE
	set /p CASE=Please enter the case name : || GOTO:ENTER_CASE

:: -----------------------------------------------------
:: Enter the examiner name
:: -----------------------------------------------------
:ENTER_NAME
	set /p NAME=Please enter the your name : || GOTO:ENTER_NAME


:: Replace spaces with underscores
set "CASE=%CASE: =_%"
set "NAME=%NAME: =_%"

:START
echo.
echo **********************************
echo.
echo LIVE FORENSIC
echo.
echo **********************************
echo.
echo.

echo Select which drive to save future results on
echo.
echo Partitioned storage devices have the same last 12 digits in their Volume Name GUIDs.
echo For example, if your Volume Name is {01234567-0000-0000-0000-123456789012},
echo '123456789012' in its Volume Name GUID but a different Mount Point.
echo.
echo.
if /I "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
	call ".\Check_USB_c\%PROCESSOR_ARCHITECTURE%\Check_USB_64.exe"
) else (
	call ".\Check_USB_c\%PROCESSOR_ARCHITECTURE%\Check_USB_32.exe"
)
echo.
echo.
echo please input your value ex) F:\
echo.
echo Your Current Working Directory is %~dp0
set /p Target_drive=Your Target Drive: 

echo.
echo.

:choice
echo Which Task do you want to execute?
echo 1. Collect Active Data
echo 2. Collect Inactive Data
echo 3. Both
echo.
echo.
set /p choice="Enter your choice: "

if "%choice%"=="1" (
    call %~dp0\active_data2.bat %CASE% %NAME% %Target_drive%%computername%_%timestamp%
	REM call %~dp0\active_data2.bat %CASE% %NAME% %Target_drive% | .\etc\Tee.exe -a %Target_drive%Active_Data_Collection_Command_Log.txt
) else if "%choice%"=="2" (
	call %~dp0\inactive_new_ver.bat %CASE% %NAME% %Target_drive%%computername%_%timestamp%
	REM call %~dp0\inactive_new_ver.bat %CASE% %NAME% %Target_drive% | .\etc\Tee.exe -a %Target_drive%Inactive_Data_Collection_Command_Log.txt
) else if "%choice%"=="3" (
	call %~dp0\active_data2.bat %CASE% %NAME% %Target_drive%%computername%_%timestamp%
	call %~dp0\inactive_new_ver.bat %CASE% %NAME% %Target_drive%%computername%_%timestamp%
) else (
    echo Invalid choice, please try again.
    goto choice
)