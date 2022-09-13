Const ForAppending = 8, AutobanIPRule = 0, ManualIPRule = 1
Const txtMyOutputFileName = "C:\path\TESTOut.csv" 'Output file CSV File can be opened with MS Excel
Dim SFTPServer, CRLF, txtServer, txtPort, txtAdminUserName, txtPassword, SiteName, myFSO, WriteStuff, selectedSite, i, Key, Key2

Set SFTPServer = CreateObject("SFTPCOMInterface.CIServer")

CRLF = Chr(13) & Chr(10) 'Use the built-in vbCrLf constant instead!

'***************************************************
'***Modify the following to match your EFT Server***
'***************************************************
txtServer = "localhost" 'input server ip or localhost
txtPort = "1100" 'input port used
txtAdminUserName = "test" 'input server admin credentials - username
txtPassword = "test" 'input server admin credentials - password
SiteName = LCase("MySite") 'input sitename in the ""

If Not Connect(txtServer, txtPort, txtAdminUserName, txtPassword) Then WScript.Quit 0

Set myFSO = CreateObject("Scripting.FileSystemObject")
Set WriteStuff = myFSO.OpenTextFile(txtMyOutputFileName, ForAppending, True)

'Header row for CSV file
'Type: AutoBan or Manually Added to List
'Address: IP that is in the list
'Banned: Dated added to banlist
'Permanent: True for permanent addition, False for expiring address
'Expires: Date that non-permanent address in Auto Banlist will drop from list.
'Reason: Reason IP was added to AutoBan list.

WriteStuff.WriteLine "Type,Address,Banned,Permanent,Expires,Reason"

Set selectedSite = Nothing

'Move through sites to find the one you're looking for
For i = 0 To SFTPServer.Sites.Count - 1
With SFTPServer.Sites.Item(i)
If LCase(.Name) = SiteName Then
For Each Key In .GetIPAccessRules
Select Case Key.Type
Case AutobanIPRule
For Each Key2 In Key.BannedIPs
WriteStuff.WriteLine Join(Array("AutoBanned", Key2.Address, CStr(Key2.Banned), CStr(Key2.Permanently), CStr(Key2.Expires), Key2.Reason), ",")
Next
Case ManualIPRule
If Not Key.Allow Then WriteStuff.WriteLine Join(Array("Manually Added", Key.Address, Key.Added, "", "", ""), ",")
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
