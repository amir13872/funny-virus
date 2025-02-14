@echo off
:: اجرای دستور با دسترسی Admin
powershell -Command "Start-Process cmd -ArgumentList '/c Set-MpPreference -DisableRealtimeMonitoring $true' -Verb RunAs"
powershell -Command "Start-Process cmd -ArgumentList '/c sc stop WinDefend' -Verb RunAs"
powershell -Command "Start-Process cmd -ArgumentList '/c sc config WinDefend start= disabled' -Verb RunAs"
echo Windows Defender Disabled Successfully!
pause
