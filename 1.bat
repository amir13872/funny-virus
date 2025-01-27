@echo off 
setlocal enabledelayedexpansion

:: فایل خروجی تعریف می‌شود
set output_file=wifi_profiles.txt

:: پیام شروع
echo Retrieving WiFi profiles... > %output_file%
echo ----------------------------------------- >> %output_file%
echo SSID                Password              >> %output_file%
echo ----------------------------------------- >> %output_file%

:: لیست پروفایل‌های وای‌فای ذخیره‌شده در سیستم را دریافت کن
for /f "tokens=*" %%A in ('netsh wlan show profiles') do (
    for /f "tokens=2 delims=:" %%B in ("%%A") do (
        set "profile_name=%%B"
        call :ProcessProfile
    )
)

:: پایان کار
echo.
echo WiFi profiles have been saved to %output_file%
:: برنامه به صورت خودکار بسته می‌شود
timeout /t 1 >nul
exit

:ProcessProfile
:: حذف فضای اضافی از نام پروفایل
set "profile_name=%profile_name:~1%"

:: تلاش برای دریافت رمز عبور پروفایل
for /f "tokens=*" %%C in ('netsh wlan show profile "%profile_name%" key^=clear') do (
    echo %%C | findstr "Key Content" >nul && (
        for /f "tokens=2 delims=:" %%D in ("%%C") do (
            set "password=%%D"
            set "password=!password:~1!"
            echo !profile_name!            !password! >> %output_file%
            goto :eof
        )
    )
)

:: در صورتی که رمز عبور پیدا نشود
echo !profile_name!            (No Password) >> %output_file%
goto :eof
