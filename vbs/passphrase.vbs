'

'
Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")
   txtServer = "localhost"
   txtPort =  "1100"
   txtUserName = "test"
   txtPassword = "test"

' On Error Resume Next
SFTPServer.Connect txtServer, txtPort, txtUserName, txtPassword
If Err.Number <> 0 Then
   WScript.Echo "Error connecting to '" & txtServer & ":" & txtPort & "' -- " & err.Description & " [" & CStr(err.Number) & "]", vbInformation, "Error"
   WScript.Quite(255)
Else
   WScript.Echo "Connected to " & txtServer
End If
set Sites=SFTPServer.Sites

For i = 0 to SFTPServer.Sites.Count-1
   set theSite=Sites.Item(i)
      SFTPhrase = theSite.SFTPKeyPassphrase
      SSLPassphrase = theSite.GetPassPhrase()
	  Wscript.Echo theSite.Name & "SFTP Passphrase " & SFTPhrase
	  Wscript.Echo theSite.Name & "SSL Passphrase " & SSLPassphrase
Next

Set theSite = nothing
Set SFTPServer = nothing
SET WriteStuff = NOTHING
SET myFSO = NOTHING