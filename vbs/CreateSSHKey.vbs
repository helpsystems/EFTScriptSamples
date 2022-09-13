Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))
txtServer = "localhost"
txtPort =  "1100"
txtAdminUserName = "Administrator"
txtPassword = "Tester!1"

If Not Connect(txtServer, txtPort, txtAdminUserName, txtPassword) Then
  WScript.Quit(0)
End If

SFTPServer.CreateSSHKey 1024, "passphrase", "C:\Private", "C:\Public.pub", False, 0, ""

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