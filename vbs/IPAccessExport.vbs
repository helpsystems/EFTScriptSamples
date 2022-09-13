Const ForAppending = 8, AutobanIPRule = 0, ManualIPRule = 1
Const txtMyOutputFileName = "TESTOut.csv" 'Output file CSV File can be opened with MS Excel
Dim SFTPServer, CRLF, txtServer, txtPort, txtAdminUserName, txtPassword, SiteName, myFSO, WriteStuff, selectedSite, i, Key, Key2

Set SFTPServer = CreateObject("SFTPCOMInterface.CIServer")

CRLF = Chr(13) & Chr(10) 'Use the built-in vbCrLf constant instead!

'***************************************************
'***Modify the following to match your EFT Server***
'***************************************************
txtServer = "192.168.102.28" 'input server ip or localhost
txtPort = "1100" 'input port used
txtAdminUserName = "insight" 'input server admin credentials - username
txtPassword = "a" 'input server admin credentials - password
SiteName = LCase("MySite") 'input sitename in the ""

If Not Connect(txtServer, txtPort, txtAdminUserName, txtPassword) Then WScript.Quit 0

Set myFSO = CreateObject("Scripting.FileSystemObject")
Set WriteStuff = myFSO.OpenTextFile(txtMyOutputFileName, ForAppending, True)

Set selectedSite = Nothing

'Move through sites to find the one you're looking for
For i = 0 To SFTPServer.Sites.Count - 1
With SFTPServer.Sites.Item(i)
If LCase(.Name) = SiteName Then
count = 1
For Each Key In .GetIPAccessRules
Select Case Key.Type
Case ManualIPRule
WriteStuff.WriteLine Join(Array(Key.Address, Key.Allow, count)
End Select
Next
Else 'LCase(SFTPServer.Sites(i).Name) <> SiteName
'WriteStuff.WriteLine "Manual Added," & key1.Address & "," & key1.added & ",,,,"
End If 'Why write "Manual Added, ..." to the .csv file here?
End With 'The Else branch is executed when the current site isn't
Next 'the one you're looking for, so why have an Else branch?

WriteStuff.Close
Set WriteStuff = Nothing
Set myFSO = Nothing

SFTPServer.Close
Set SFTPServer = Nothing

MsgBox "Banned IPs can be found in the file """ & txtMyOutputFileName & """", vbInformation

Function Connect(serverOrIpAddress, port, username, password)
On Error Resume Next
SFTPServer.Connect serverOrIpAddress, port, username, password
Connect = (Err.Number = 0)

If Not Connect Then
MsgBox "Error connecting to '" & serverOrIpAddress & ":" & port & "' -- " & _
Err.Description & " [" & CStr(Err.Number) & "]", vbInformation, "Error"
End If
End Function 
