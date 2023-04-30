@echo off
setlocal enabledelayedexpansion

for /f "tokens=2" %%a in ('tasklist ^| findstr /r /b "[A-Za-z]"') do (
    echo [%timestamp%] Starting procdump for process: %%a >> %TimeStamp%
    echo Creating memory dump for process: %%a
    "%sysinternals%\procdump64.exe" -ma "%%a" "%Virtual_Memory_dir%\%%a_memory_dump.dmp"
    echo [%timestamp%] Finished procdump for process: %%a >> %TimeStamp%
    echo Calculating hash for process: %%a
    %hash%\hashdeep64.exe "%Virtual_Memory_dir%\%%a_memory_dump.dmp" > "%Virtual_Memory_dir%\%%a_memory_dump_hash.txt"
    echo [%timestamp%] HASH for process %%a >> %TimeStamp%
)
pause 
