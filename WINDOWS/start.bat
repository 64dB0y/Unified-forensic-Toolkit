@echo off
REM clear all remains on cmd
cls
:: -----------------------------------------------------
:: VARIABLEs
:: -----------------------------------------------------
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

:START
echo.
echo ******************
echo LIVE FORENSIC
echo ******************
echo.
echo.

echo Select which drive to save future results on
echo.
echo Partitioned storage devices have the same last 12 digits in their Volume Name GUIDs.
echo For example, if your Volume Name is {01234567-0000-0000-0000-123456789012},
echo '123456789012' in its Volume Name GUID but a different Mount Point.
echo.
echo.
call Check_USB_c\Check_USB_64.exe
echo.
echo.
echo please input your value ex) F:\
echo.
echo Your Current Working Directory is %~dp0
set /p Target_drive=Your Target Drive:

echo.
echo.
:: 현재는 1번인 활성데이터만 가능하다
:choice
echo Which Task do you want to execute?
echo 1. Collect Active Data
echo 2. Collect Inactive Data
echo 3. Both
echo.
echo.
set /p choice="Enter your choice: "

if "%choice%"=="1" (
    call %~dp0\_ACTIVE2.bat %CASE% %NAME% %Target_drive%
) else (
    echo Invalid choice, please try again.
    goto choice
)
