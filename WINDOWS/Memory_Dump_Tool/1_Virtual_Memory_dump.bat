@echo off
setlocal enabledelayedexpansion

set "sysinternals=%~1"
set "Virtual_Memory_dir=%~2"
set "_TimeStamp=%~3"
set "hash=%~4"

echo Choose dump type:
echo 1. Full memory dump
echo 2. Kernel memory dump
echo 3. Both
set /p dumpType=Enter your choice: 

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "procdump=procdump64.exe"
    set "hashdeep=hashdeep64.exe"
) else (
    set "procdump=procdump.exe"
    set "hashdeep=hashdeep.exe"
)

for /f "tokens=2" %%a in ('tasklist ^| findstr /r /b "[A-Za-z]"') do (
    set "timestamp=!date! !time!"
    if %dumpType%==1 (
        echo [%_TimeStamp%] Starting procdump for process: %%a >> %_TimeStamp%
        echo Creating full memory dump for process: %%a
        if not exist "%Virtual_Memory_dir%\full_memory" mkdir "%Virtual_Memory_dir%\full_memory"
        if not exist "%Virtual_Memory_dir%\full_memory\hash" mkdir "%Virtual_Memory_dir%\full_memory\hash"
        "!sysinternals!\%procdump%" -ma "%%a" "%Virtual_Memory_dir%\full_memory\%%a_memory_dump.dmp"
        echo [!timestamp!] Finished procdump for process: %%a >> %_TimeStamp%
        echo Calculating hash for process: %%a
        "!hash!\%hashdeep%" "%Virtual_Memory_dir%\full_memory\%%a_memory_dump.dmp" > "%Virtual_Memory_dir%\full_memory\hash\%%a_memory_dump_hash.txt"
        echo [!timestamp!] HASH for process %%a >> %_TimeStamp%
    ) else if %dumpType%==2 (
        echo [!timestamp!] Starting procdump for process: %%a >> %_TimeStamp%
        echo Creating kernel memory dump for process: %%a
        if not exist "%Virtual_Memory_dir%\kernel_memory" mkdir "%Virtual_Memory_dir%\kernel_memory"
        if not exist "%Virtual_Memory_dir%\kernel_memory\hash" mkdir "%Virtual_Memory_dir%\kernel_memory\hash"
        "!sysinternals!\%procdump%" -mk "%%a" "%Virtual_Memory_dir%\kernel_memory\%%a_kernel_memory_dump.dmp"
        echo [!timestamp!] Finished procdump for process: %%a >> %_TimeStamp%
        echo Calculating hash for process: %%a
        "!hash!\%hashdeep%" "%Virtual_Memory_dir%\kernel_memory\%%a_kernel_memory_dump.dmp" > "%Virtual_Memory_dir%\kernel_memory\hash\%%a_kernel_memory_dump_hash.txt"
        echo [!timestamp!] HASH for process %%a >> %_TimeStamp%
    ) else if %dumpType%==3 (
        echo [!timestamp!] Starting procdump for process: %%a >> %_TimeStamp%
        echo Creating full memory dump for process: %%a
        if not exist "%Virtual_Memory_dir%\full_memory" mkdir "%Virtual_Memory_dir%\full_memory"
        if not exist "%Virtual_Memory_dir%\full_memory\hash" mkdir "%Virtual_Memory_dir%\full_memory\hash"
        "!sysinternals!\%procdump%" -ma "%%a" "%Virtual_Memory_dir%\full_memory\%%a_memory_dump.dmp"
        echo [!timestamp!] Finished procdump for process: %%a >> %_TimeStamp%
        echo Calculating hash for process: %%a
        "!hash!\%hashdeep%" "%Virtual_Memory_dir%\full_memory\%%a_memory_dump.dmp" > "%Virtual_Memory_dir%\full_memory\hash\%%a_memory_dump_hash.txt"
        echo [!timestamp!] HASH for process %%a >> %_TimeStamp%

        echo [!timestamp!] Starting procdump for process: %%a >> %_TimeStamp%
        echo Creating kernel memory dump for process: %%a
        if not exist "%Virtual_Memory_dir%\kernel_memory" mkdir "%Virtual_Memory_dir%\kernel_memory"
        if not exist "%Virtual_Memory_dir%\kernel_memory\hash" mkdir "%Virtual_Memory_dir%\kernel_memory\hash"
        "!sysinternals!\%procdump%" -mk "%%a" "%Virtual_Memory_dir%\kernel_memory\%%a_kernel_memory_dump.dmp"
        echo [!timestamp!] Finished procdump for process: %%a >> %_TimeStamp%
        echo Calculating hash for process: %%a
        "!hash!\%hashdeep%" "%Virtual_Memory_dir%\kernel_memory\%%a_kernel_memory_dump.dmp" > "%Virtual_Memory_dir%\kernel_memory\hash\%%a_kernel_memory_dump_hash.txt"
        echo [!timestamp!] HASH for process %%a >> %_TimeStamp%
    )
)
pause