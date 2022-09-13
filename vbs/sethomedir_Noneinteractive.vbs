Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))

txtServer = "localhost"
txtPort = "1111"
txtAdminUserName = "eftadmin"
txtPassword = "a"
userName = "mike1"
siteName = "GS"
homeFolder = "/noexisty"

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

If Not selectedSite Is Nothing Then

  set userSettings = selectedSite.GetUserSettings(userName)
  
'set home directory
userSettings.SetHomeDirString(homeFolder)

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