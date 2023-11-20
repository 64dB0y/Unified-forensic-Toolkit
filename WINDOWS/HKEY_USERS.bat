@echo off
setlocal enabledelayedexpansion

echo Enumerating HKEY_USERS subkeys...
echo Saving HKEY_USERS\.DEFAULT...
reg save "HKEY_USERS\.DEFAULT" ".\DEFAULT_backup.reg" /y
echo [!timestamp!] REG SAVE HKEY_USERS\.DEFAULT >> %_TimeStamp%
%hash%\hashdeep64.exe -c sha1,md5,sha256 ".\DEFAULT_backup.reg" > "%SYSTEM_INFO_HASH%\DEFAULT_backup_HASH.txt"
echo [!timestamp!] DEFAULT HASH >> %_TimeStamp%

for /f "tokens=1*" %%a in ('reg query HKU ^| findstr /r /b "HKEY_USERS\\S-1-5"') do (
    set "subkey=%%a"
    echo Saving !subkey!...
    reg save "!subkey!" ".\!subkey:~11!_backup.reg" /y
    echo [!timestamp!] REG SAVE !subkey! >> %_TimeStamp%
    %hash%\hashdeep64.exe -c sha1,md5,sha256 ".\!subkey:~11!_backup.reg" > "%SYSTEM_INFO_HASH%\!subkey:~11!_backup_HASH.txt"
    echo [!timestamp!] !subkey:~11! HASH >> %_TimeStamp%
)

echo All HKEY_USERS subkeys have been saved.

echo Moving registry backup files to %SYSTEM_INFO_Dir%\HKEY_USERS
md "%SYSTEM_INFO_Dir%\HKEY_USERS"
move /y "*.reg" "%SYSTEM_INFO_Dir%\HKEY_USERS"
