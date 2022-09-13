'
' FILE: get_date_user_last_connected.vbs
' CREATED: 10-26-2020 (jbranan@globalscape.com)
' UPDATED: 10-26-2020 (jhulme@globalscape.com)
' PURPOSE: Returns date/time a user last connected
' **This script is provided AS IS to our customers as a courtesy no support is provided in modifying or debugging this script.
' 
' Set username variable with the username of the user you would like to view
Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")
CRLF = (Chr(13)& Chr(10))
'Modify the following variables to match your environment
   txtServer = "localhost"
   txtPort =  "1100"
   txtUserName = "username"
   txtPassword = "password"
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
         MsgBox "Username: " &CStr(username)&" " & "Last Connection Time: " & CStr(userSettings.LastConnectionTime)

'Close all variables
SFTPServer.Close
Set theSite = nothing
Set SFTPServer = nothing