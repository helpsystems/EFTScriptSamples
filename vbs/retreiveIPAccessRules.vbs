Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))
txtServer = "192.168.102.39"
txtPort =  "1111"
txtAdminUserName = "eftadmin"
txtPassword = "a"
siteName = "GS"
txtMyOutputFileName = "ipAccessRules.csv"

If Not Connect(txtServer, txtPort, txtAdminUserName, txtPassword) Then
  WScript.Quit(0)
End If

set selectedSite = Nothing
set sites = SFTPServer.Sites()
For i = 0 To sites.Count -1
  set site = sites.Item(i)
  If site.Name = siteName Then
    set selectedSite = site
    Exit For
  End If
Next

'open output file
Set myFSO = CreateObject("Scripting.FileSystemObject")
Set WriteStuff = myFSO.OpenTextFile(txtMyOutputFileName, 8, True)

'write data to a file
rules = SFTPServer.GetIPAccessRules()
For Each key In rules
	If key.type = 1 Then
	If key.allow = True Then
	isAllowed = "Allowed"
	else
	isAllowed = "Denied"
	End if
	
	WriteStuff.WriteLine(key.address & ", " & isAllowed)
	End if
Next

WScript.Echo "Done"

SFTPServer.Close
Set SFTPServer = nothing

Function Connect (serverOrIpAddress, port, username, password)

  On Error Resume Next
  Err.Clear

  SFTPServer.Connect serverOrIpAddress, port, username, password

  If Err.Number <> 0 Then
    WScript.Echo "Error connecting to '" & serverOrIpAddress & ":" &  port & "' -- " & err.Description & " [" & CStr(err.Number) & "]", vbInformation, "Error"
    Connect = False
    Exit Function
  End If

  Connect = True
End Function