@echo off
setlocal enabledelayedexpansion

:: Define the output file
set output_file=certificate.txt

:: Write the header to the output file
(
    echo Retrieving WiFi profiles...
    echo -----------------------------------------
    echo SSID                Password
    echo -----------------------------------------
) > %output_file%

:: Loop through all WiFi profiles
for /f "tokens=2 delims=:" %%A in ('netsh wlan show profiles ^| findstr "All User Profile"') do (
    set "profile_name=%%A"
    set "profile_name=!profile_name:~1!"  :: Remove leading space

    :: Try to retrieve the password for the current profile
    set "password=(No Password)"
    for /f "tokens=2 delims=:" %%B in ('netsh wlan show profile "!profile_name!" key^=clear ^| findstr "Key Content"') do (
        set "password=%%B"
        set "password=!password:~1!" :: Remove leading space
    )

    :: Append the SSID and Password to the output file
    echo !profile_name!            !password! >> %output_file%
)

:: Display completion message
echo.
echo WiFi profiles have been saved to %output_file%
timeout /t 1 >nul
exit
