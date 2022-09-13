Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))
txtServer = "localhost"
txtPort =  "1100"
txtAdminUserName = "eftadmin"
txtPassword = "a"

If Not Connect(txtServer, txtPort, txtAdminUserName, txtPassword) Then
  WScript.Quit(0)
End If

set Sites=SFTPServer.Sites 
set oSite = Sites.Item(0)

WSCript.Echo oSite.Name
dim folders 
'folders = oSite.GetFolderList("/")
if True = oSite.IsFolderVirtual("/wd") then
WSCript.Echo "/wd is virtual."
end if

if True = oSite.IsFolderVirtual("/Usr") then
WSCript.Echo "/Usr is virtual."
end if

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