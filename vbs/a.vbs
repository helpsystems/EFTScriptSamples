Dim FSO
Set FSO = CreateObject("Scripting.FileSystemObject")

' Define source file name.
sourceFile = "C:\Users\jbranan\Desktop\source\Report File.xml"
' Define target file name.
destinationFile = "C:\Users\jbranan\Desktop\destination\Report File.xml"
'opy source to target.
FSO.CopyFile sourceFile, destinationFile
'Function UnicodeFileCopy(src As String, dst As String) As String
'	On Error Resume Next
'	FileCopy src, dst
'	UnicodeFileCopy = Err.Description
'End Function
'Sub Main
'                Call          UnicodeFileCopy"C:\Users\jbranan\Desktop\source\Report File.xml", "C:\Users\jbranan\Desktop'\destination\Report File.xml"
'End Sub