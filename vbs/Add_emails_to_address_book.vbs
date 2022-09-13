Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))
txtServer = "192.168.102.28"
txtPort =  "1100"
txtAdminUserName = "eftadmin"
txtPassword = "a"

If Not Connect(txtServer, txtPort, txtAdminUserName, txtPassword) Then
  WScript.Quit(0)
End If

strEmailList = SFTPServer.SMTPAddressBook
    For j = 0 to 1000
       If strEmailList <> "" Then
strEmailList = strEmailList + "; "
End If
strEmailList = strEmailList + Cstr(j) +"<" + Cstr(j) + "@SomeServer.com>"
    Next

SFTPServer.SMTPAddressBook = strEmailList

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