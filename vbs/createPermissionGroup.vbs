Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))
txtServer = "localhost"
txtPort =  "1100"
txtAdminUserName = "eftadmin"
txtPassword = "a"

'Input boxes **do not modify**
msgTitle = "Globalscape EFT Server"
siteMessage = "Enter the site name:"
groupMessage = "Enter the name of the new group"

If Not Connect(txtServer, txtPort, txtAdminUserName, txtPassword) Then
  WScript.Quit(0)
End If

siteName = InputBox (siteMessage, msgTitle)

set selectedSite = Nothing
set sites = SFTPServer.Sites()
For i = 0 To sites.Count -1
  set site = sites.Item(i)
  If site.Name = siteName Then
    set selectedSite = site
    Exit For
  End If
Next

'physical or virtual?
txtGroup = InputBox (groupMessage, msgTitle)

selectedSite.CreatePermissionGroup(txtGroup)

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