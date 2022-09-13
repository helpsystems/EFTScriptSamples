Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))

welcomeMsg = "The script you are running is used to return the date and time which a user's password is going to expire."
msgTitle = "Globalscape EFT Server"
serverMessage = "Enter EFT Server IP..."
portMessage = "Enter EFT Server Port..."
adminMessage = "Enter EFT Admin username..."
passMessage = "Enter EFT Admin password..."
siteMessage = "Enter the site name where the user is located..."
userMessage = "Enter the Username for which you would like to retrieve the expiration date and time..."

'Display welcome message
Call MsgBox (welcomeMsg, , msgTitle)

'Input Prompts
txtServer = InputBox (serverMessage, msgTitle)
txtPort = InputBox (portMessage, msgTitle)
txtAdminUserName = InputBox(adminMessage, msgTitle)
txtPassword = InputBox(passMessage, msgTitle)

If Not Connect(txtServer, txtPort, txtAdminUserName, txtPassword) Then
  WScript.Quit(0)
End If

userName = InputBox (userMessage, msgTitle)
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

If Not selectedSite Is Nothing Then

  set userSettings = selectedSite.GetUserSettings(userName)
  
'getting pass expiration date
If userSettings.IsPasswordAgeLimited(pDate) Then
    dtAccPssExp = Cstr(pDate)
    Wscript.Echo "User " +userName + "'s Password Expires on " + dtAccPssExp
    Else
    Wscript.Echo "User " + userName + "'s Password does not expire"
End If

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