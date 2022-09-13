Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))
txtServer = "192.168.102.39"
txtPort =  "1111"
txtAdminUserName = "eftadmin"
txtPassword = "a"

If Not Connect(txtServer, txtPort, txtAdminUserName, txtPassword) Then
  WScript.Quit(0)
End If

userName = "test"
siteName = "GS"
set selectedSite = Nothing
set sites = SFTPServer.Sites()
For i = 0 To sites.Count -1
  set site = sites.Item(i)
  If site.Name = siteName Then
    set selectedSite = site
    Exit For
  End If
Next

If Not selectedSite Is Nothing Then

'selectedSite.ChangeUserPassword userName, "abcd", 0
selectedSite.ChangeUserPassword userName, "test1", 0
'$1$abcdefg$M72mUVrUAZrOg1C7Nl1qM.

  set userSettings = selectedSite.GetUserSettings(userName)

'userSettings.MaxInactivePeriod = 30

End If

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