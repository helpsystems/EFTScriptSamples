Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))

welcomeMsg = "The script you are running is used to create a new settings tempalte for a specified site"
msgTitle = "Globalscape EFT Server"
serverMessage = "Enter EFT Server IP..."
portMessage = "Enter EFT Server Port..."
adminMessage = "Enter EFT Admin username..."
passMessage = "Enter EFT Admin password..."
siteMessage = "Enter the site name where the user is located..."
templateMessage = "Enter New Template Name"

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

siteName = InputBox (siteMessage, msgTitle)
templateName = InputBox (templateMessage, msgTitle)

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

selectedSite.CreateSettingsLevel(templateName)

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