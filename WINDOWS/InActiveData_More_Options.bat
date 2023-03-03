@echo off

:: 설정
set "TARGET_DRIVE=C:"
set "FORENSIC_TOOL_DIR=tools"
set "FORECOPY_HANDY_DIR=forecopy_handy"
set "AUTORUNS_TOOL=%FORENSIC_TOOL_DIR%\autoruns.exe"
set "FTK_IMAGER_TOOL=%FORENSIC_TOOL_DIR%\ftkimager"
set "AUTOPSY_TOOL=%FORENSIC_TOOL_DIR%\autopsy-4.18.0-win64\bin\autopsy.exe"

:: 결과물이 저장될 디렉토리 설정
set "RESULT_DIR=result"

:: 결과물이 저장될 디렉토리 생성
if not exist "%RESULT_DIR%" mkdir "%RESULT_DIR%"

:menu
cls
echo 디지털 포렌식 수행 스크립트
echo 1. 디스크 이미지 생성
echo 2. 레지스트리 정보 수집
echo 3. Windows 이벤트 로그 정보 수집
echo 4. cmd 파일 이력 정보 수집
echo 5. 사용자 계정 정보 수집
echo 6. 시스템 정보 수집
echo 7. 각종 로그 수집
echo 8. 부팅 프로그램 정보 수집
echo 9. 휴지통 정보 수집
echo 10. 브라우저 사용 흔적 수집
echo 11. 임시 파일 정보 수집
echo 12. 시스템 복원 지점 수집
echo 13. 외부 저장매체 정보 수집
echo 14. 바로가기 정보 수집
echo 15. 점프리스트 정보 수집
echo 0. 종료
set /p "choice=작업 번호를 입력하세요: "

if /i "%choice%"=="all" (
    set "current_step=1"
    set "final_step=15"
    goto run_all
) else (
    set "current_step=%choice%"
    set "final_step=%choice%"
)

:run_all
if /i "%choice%"=="all" (
    echo 모든 작업을 수행합니다.
    set "current_step=1"
    set "final_step=15"
)

:disk_image
if %current_step%==1 (
    echo 디스크 이미지 생성
    if not exist "%RESULT_DIR%\disk_image\" mkdir "%RESULT_DIR%\disk_image\"
    if not exist "%RESULT_DIR%\disk_image\disk.img" (
        %FTK_IMAGER_TOOL% .%TARGET_DRIVE% "%RESULT_DIR%\disk_image\disk.img" 2>&1
    ) else (
        echo 이미 존재하는 디스크 이미지: %RESULT_DIR%\disk_image\disk.img
    )
    set /a current_step+=1
)

:reg_info
if %current_step%==2 (
    echo "레지스트리 정보 수집"
    mkdir %RESULT_DIR%\Reg_Info
    cd /d %RESULT_DIR%\Reg_Info
    reg save HKLM\SYSTEM system.reg
    reg save HKLM\SOFTWARE software.reg
    reg save HKLM\SECURITY security.reg
    reg save HKLM\SAM sam.reg
    reg save HKCU NTUSER.dat
    reg save HKCU\Software\Classes UsrClass.dat
    cd ..
    echo "레지스트리 정보 수집 완료"
    set /a current_step+=1
)

:event_log
if %current_step%==3 (
echo "Windows 이벤트 로그 정보 수집"
mkdir %RESULT_DIR%\Event_Log
cd /d %RESULT_DIR%\Event_Log
wevtutil epl System system_log.evtx
wevtutil epl Application application_log.evtx
wevtutil epl Security security_log.evtx
echo "Windows 이벤트 로그 정보 수집 완료"
set /a current_step+=1
)

:cmd_history
if %current_step%==4 (
echo "cmd 파일 이력 정보 수집"
mkdir %RESULT_DIR%\Cmd_History
cd /d %RESULT_DIR%\Cmd_History
for /f "tokens=1,2* delims= " %%a in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Command Processor" /v AutoRun') do set autorun=%%c
echo %autorun% > autorun.cmd
echo "cmd 파일 이력 정보 수집 완료"
set /a current_step+=1
)

:user_account
if %current_step%==5 (
echo "사용자 계정 정보 수집"
mkdir %RESULT_DIR%\User_Account
cd /d %RESULT_DIR%\User_Account
net user > user_list.txt
echo "사용자 계정 정보 수집 완료"
set /a current_step+=1
)

:system_info
if %current_step%==6 (
echo "시스템 정보 수집"
mkdir %RESULT_DIR%\System_Info
cd /d %RESULT_DIR%\System_Info
systeminfo > system_info.txt
echo "시스템 정보 수집 완료"
set /a current_step+=1
)

:log
if %current_step%==7 (
echo "각종 로그 수집"
mkdir %RESULT_DIR%\log_files
wevtutil.exe epl System %RESULT_DIR%\log_files\System_log.evtx
wevtutil.exe epl Application %RESULT_DIR%\log_files\Application_log.evtx
wevtutil.exe epl Security %RESULT_DIR%\log_files\Security_log.evtx
wevtutil.exe epl Setup %RESULT_DIR%\log_files\Setup_log.evtx
netsh advfirewall firewall show rule name=all | findstr Rule | findstr -v "System" | findstr -v "Rule Name:" > %RESULT_DIR%\log_files\firewall_rules.txt
wevtutil.exe qe /lf /f:text /rd:true /c:1 /q:"*[System/EventID=4624]" > %RESULT_DIR%\log_files\logon_events.txt
wevtutil.exe qe /lf /f:text /rd:true /c:1 /q:"*[System/EventID=4688]" > %RESULT_DIR%\log_files\process_events.txt
echo Log files collected.
set /a current_step+=1
)

:startup_program
if %current_step%==8 (
echo "부팅 프로그램 정보 수집"
mkdir %RESULT_DIR%\Startup_Program
cd /d %RESULT_DIR%\Startup_Program
%AUTORUNS_TOOL% /a /m * > startup_program.txt
echo "부팅 프로그램 정보 수집 완료"
set /a current_step+=1
)

:recycle_bin
if %current_step%==9 (
echo "휴지통 정보 수집"
mkdir %RESULT_DIR%\Recycle_Bin
cd /d %RESULT_DIR%\Recycle_Bin
for /f "tokens=2 delims=:" %%d in ('wmic logicaldisk where drivetype^=2 get name') do (
if exist "%%d$Recycle.Bin" (
mkdir "%%d$Recycle.Bin"
%FORECOPY_HANDY_DIR%\forecopy.exe "%%d$Recycle.Bin" "%%d$Recycle.Bin" /r /q /nopad /nosec /s /i /ns /nc /e
)
)
echo "휴지통 정보 수집 완료"
set /a current_step+=1
)

:browser_history
if %current_step%==10 (
echo "브라우저 사용 흔적 수집"
mkdir %RESULT_DIR%\Browser_History
cd /d %RESULT_DIR%\Browser_History
mkdir chrome
mkdir firefox
mkdir edge
mkdir ie
%FORECOPY_HANDY_DIR%\forecopy.exe -source %LOCALAPPDATA%\Google\Chrome\User Data -dest chrome -delete -skipJunctions
%FORECOPY_HANDY_DIR%\forecopy.exe -source %APPDATA%\Mozilla\Firefox\Profiles -dest firefox -delete -skipJunctions
%FORECOPY_HANDY_DIR%\forecopy.exe -source %LOCALAPPDATA%\Microsoft\Edge\User Data -dest edge -delete -skipJunctions
%FORECOPY_HANDY_DIR%\forecopy.exe -source %LOCALAPPDATA%\Microsoft\Windows\WebCache -dest ie -delete -skipJunctions
echo "브라우저 사용 흔적 수집 완료"
set /a current_step+=1
)

:temp_file
if %current_step%==11 (
echo "임시 파일 정보 수집"
mkdir %RESULT_DIR%\Temp_Files
cd /d %RESULT_DIR%\Temp_Files
%FORENSIC_TOOL_DIR%\tmp_file_finder.exe -d "%TARGET_DRIVE%" -o output.txt
echo "임시 파일 정보 수집 완료"
set /a current_step+=1
)

:system_restore
if %current_step%==12 (
echo "시스템 복원 지점 정보 수집"
mkdir %RESULT_DIR%\System_Restore
cd /d %RESULT_DIR%\System_Restore
reg save HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore system_restore.reg
echo "시스템 복원 지점 정보 수집 완료"
set /a current_step+=1
)


:external_device
if %current_step%==13 (
echo "외부 저장매체 정보 수집"
mkdir %RESULT_DIR%\External_Device
cd /d %RESULT_DIR%\External_Device
%FORENSIC_TOOL_DIR%\usb_history.exe -csv report.csv
echo "외부 저장매체 정보 수집 완료"
set /a current_step+=1
)

:shortcut_file
if %current_step%==14 (
echo "바로가기 파일 정보 수집"
mkdir %RESULT_DIR%\Shortcut_Files
cd /d %RESULT_DIR%\Shortcut_Files
%FORENSIC_TOOL_DIR%\lnk_parser.exe "%TARGET_DRIVE%" > output.txt
echo "바로가기 파일 정보 수집 완료"
set /a current_step+=1
)

:jump_list
if %current_step%==15 (
echo "점프리스트 정보 수집"
mkdir %RESULT_DIR%\Jump_List
cd /d %RESULT_DIR%\Jump_List
%FORENSIC_TOOL_DIR%\jump_list_parser.exe -f -o jump_list.txt
echo "점프리스트 정보 수집 완료"
)
if %current_step%==%final_step% (
    echo All steps have been completed.
    echo.
)
