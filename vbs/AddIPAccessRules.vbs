Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))
txtServer = "192.168.102.28"
txtPort =  "1100"
txtAdminUserName = "eftadmin"
txtPassword = "a"
siteName = "GS2"

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

'To create an entry use the line below
Dim isAllowEntry : isAllowEntry = True
For index = 1 To 4
	For index2 = 1 To 255
		selectedSite.AddIPAccessRule "192.168." & index & "." & index2, isAllowEntry, 0
	Next
Next

'Remove IPAccessRule at position
'For index = 1 To 9408
	'selectedSite.RemoveIPAccessRule(1)
	'Wscript.echo "Removing IP Access Rule: " & index
'Next

'Old functions:
'allowedIPs = SFTPServer.GetAllowedMasks
'For each ip in allowedIPs
'  WScript.Echo "Allowed: " + ip
'Next

'deniedIPs = SFTPServer.GetDeniedMasks
'For each ip in deniedIPs
'  WScript.Echo "Denied: " + ip
'Next

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