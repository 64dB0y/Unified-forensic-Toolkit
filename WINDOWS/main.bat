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

:REPLACE_SPACES_CASE
if "%CASE: =_%" neq "%CASE%" (
    set "CASE=%CASE: =_%"
    goto REPLACE_SPACES_CASE
)

:REPLACE_SPACES_NAME
if "%NAME: =_%" neq "%NAME%" (
    set "NAME=%NAME: =_%"
    goto REPLACE_SPACES_NAME
)

set Procmon=
set kill_Procmon=
set psexec=
set "sysinternals=%~dp0sysinternalsSuite"

if %PROCESSOR_ARCHITECTURE%==AMD64 (
	set Procmon=%sysinternals%\Procmon64.exe
	set kill_Procmon=Procmon64.exe
	set psexec=%sysinternals%\PsExec64.exe
) else (
	set Procmon=%sysinternals%\Procmon.exe
	set kill_Procmon=Procmon.exe
	set psexec=%sysinternals%\PsExec.exe
)
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

:: If the last character of the entered drive string is not '\', add '\'
if not "%Target_drive:~-1%"=="\" set Target_drive=%Target_drive%\

set foldername=%Target_drive%%computername%_%timestamp%
mkdir "%foldername%"
echo "created %foldername%"

echo.
echo.

:ask_procmon
echo Do you want to track file creation activities using Procmon?
echo Warning: Procmon loads a system driver to monitor activities. Safely unloading this driver may require a system reboot.
set /p track_files="Enter your choice (Y/N): "
if /I "%track_files%"=="Y" (
    set run_procmon=1
) else if /I "%track_files%"=="N" (
    set run_procmon=0
) else (
    echo Invalid choice, please try again.
    goto ask_procmon
)

:choice
echo Which Task do you want to execute?
echo 1. Collect Active Data
echo 2. Collect Inactive Data
echo 3. Both
echo.
echo.
set /p choice="Enter your choice: "

if "%run_procmon%"=="1" (
    REM %psexec% -d %Procmon% /accepteula /Quiet /Minimized /BackingFile %foldername%\procmon_log.pml
    START /B /MIN %Procmon% /accepteula /Quiet /Minimized /BackingFile %foldername%\procmon_log.pml
)

if "%choice%"=="1" (
    call %~dp0\active_data2.bat "%CASE%" "%NAME%" %Target_drive%%computername%_%timestamp%
    REM call %~dp0\active_data2.bat %CASE% %NAME% %Target_drive% | .\etc\Tee.exe -a %Target_drive%Active_Data_Collection_Command_Log.txt
) else if "%choice%"=="2" (
    call %~dp0\inactive_new_ver_ver.bat "%CASE%" "%NAME%" %Target_drive%%computername%_%timestamp%
    REM call %~dp0\inactive_new_ver.bat %CASE% %NAME% %Target_drive% | .\etc\Tee.exe -a %Target_drive%Inactive_Data_Collection_Command_Log.txt
) else if "%choice%"=="3" (
    call %~dp0\active_data2.bat "%CASE%" "%NAME%" %Target_drive%%computername%_%timestamp%
    call %~dp0\inactive_new_ver_ver.bat "%CASE%" "%NAME%" %Target_drive%%computername%_%timestamp%
) else (
    echo Invalid choice, please try again.
    goto choice
)

if "%run_procmon%"=="1" (
    %Procmon% /Terminate
    timeout /t 5 /nobreak >nul

    REM The "GOTO CheckProcmonDrivers" line is commented out because there have been issues with properly unloading the Procmon Driver or with insufficient permissions preventing the deletion of the Procmon.sys file. This line has been commented out for now. Once these issues are resolved, the comment can be removed from "GOTO CheckProcmonDrivers" and added to the line immediately below it, "GOTO :eof".
    REM GOTO CheckProcmonDrivers
    GOTO :eof
)

:CheckProcmonDrivers
echo.
echo Checking for PROCMON23 or PROCMON24 filter drivers...
echo Note: Unloading or deleting a driver is a sensitive operation. 
echo It's recommended only if you're experiencing issues with the driver.
echo A system reboot will automatically unload drivers.
echo.
echo.
set /p confirmProceed="Proceed with unloading/deleting drivers? (Y/N): "
if /I "!confirmProceed!"=="Y" (
    :: Check the list of filter drivers and automatically unload PROCMON23 or PROCMON24
    set unloadSuccess=0
    for /f "tokens=1" %%i in ('fltmc') do (
        if "%%i"=="PROCMON23" (
            fltmc unload PROCMON23
            if errorlevel 1 (
                echo Failed to unload PROCMON23.
                set /p confirmDelete="Delete PROCMON23.sys from C:\Windows\System32\drivers? (Y/N): "
                if /I "!confirmDelete!"=="Y" (
                    if exist C:\Windows\System32\drivers\PROCMON23.sys (
                        del /F /A:H C:\Windows\System32\drivers\PROCMON23.sys
                        echo PROCMON23.sys has been deleted.
                    ) else (
                        echo PROCMON23.sys not found.
                    )
                ) else (
                    echo File deletion cancelled.
                )
            ) else (
                set unloadSuccess=1
                echo Unloaded PROCMON23.
            )
        )
        if "%%i"=="PROCMON24" (
            fltmc unload PROCMON24
            if errorlevel 1 (
                echo Failed to unload PROCMON24.
                set /p confirmDelete="Delete PROCMON24.sys from C:\Windows\System32\drivers? (Y/N): "
                if /I "!confirmDelete!"=="Y" (
                    if exist C:\Windows\System32\drivers\PROCMON24.sys (
                        del /F /A:H C:\Windows\System32\drivers\PROCMON24.sys
                        echo PROCMON24.sys has been deleted.
                    ) else (
                        echo PROCMON24.sys not found.
                    )
                ) else (
                    echo File deletion cancelled.
                )
            ) else (
                set unloadSuccess=1
                echo Unloaded PROCMON24.
            )
        )
    )
    if "%unloadSuccess%"=="0" (
        echo PROCMON23 or PROCMON24 not found.
        echo Current loaded filter drivers:
        fltmc
        set /p driverName="Enter the name of the filter driver to unload: "
        fltmc unload !driverName!
        if errorlevel 1 (
            echo Failed to unload !driverName!.
            echo Error 0x801f0010: The filter driver is still in use or cannot be safely unloaded.
            set /p confirmDelete="Delete !driverName!.sys from C:\Windows\System32\drivers? (Y/N): "
            if /I "!confirmDelete!"=="Y" (
                if exist C:\Windows\System32\drivers\!driverName!.sys (
                    del /F /A:H C:\Windows\System32\drivers\!driverName!.sys
                    echo !driverName!.sys has been deleted.
                ) else (
                    echo !driverName!.sys not found.
                )
            ) else (
                echo File deletion cancelled.
            )
        ) else (
            echo Unloaded !driverName!.
        )
    )
) else (
    echo Unloading / deleting drivers cancelled.
)