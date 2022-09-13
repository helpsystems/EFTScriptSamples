Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))

welcomeMsg = "The script you are running is used to retrieve admin users that have administration permissions in EFT"
msgTitle = "Globalscape EFT Server"
serverMessage = "Enter EFT Server IP..."
portMessage = "Enter EFT Server Port..."
adminMessage = "Enter EFT Admin username..."
passMessage = "Enter EFT Admin password..."
txtMyOutputFileName = "Admin-Users.csv"

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

Set myFSO = CreateObject("Scripting.FileSystemObject")
Set WriteStuff = myFSO.OpenTextFile(txtMyOutputFileName, 8, True)

For Each admin In SFTPServer.AdminAccounts
WriteStuff.WriteLine(admin.login)
Next

Wscript.echo "done"

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