Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")
CRLF = (Chr(13)& Chr(10))

   txtServer = "192.168.102.37"
   txtPort =  "1100"
   txtUserName = "admin"
   txtPassword = "Bran1739!"
   txtSiteName = "MySite"
   username = "a"

SFTPServer.Connect txtServer, txtPort, txtUserName, txtPassword
If Err.Number <> 0 Then
   WScript.Echo "Error connecting to '" & txtServer & ":" & txtPort & "' -- " & err.Description & " [" & CStr(err.Number) & "]", vbInformation, "Error"
   WScript.Quite(255)
Else
   WScript.Echo "Connected to " & txtServer
End If
set Sites=SFTPServer.Sites
set theSite = Nothing
set sites = SFTPServer.Sites()
For i = 0 To sites.Count -1
	set site = sites.Item(i)
		If site.Name = txtSiteName Then
			set theSite = site
			Exit For
		End If
Next
         set userSettings = theSite.GetUserSettings(username)
         MsgBox "Username: " &CStr(username)&" " & "Account creation time: " & CStr(userSettings.LastConnectionTime)

SFTPServer.Close
Set theSite = nothing
Set SFTPServer = nothing