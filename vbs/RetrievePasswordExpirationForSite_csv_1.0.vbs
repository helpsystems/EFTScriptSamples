Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))

welcomeMsg = "The script you are running is used to return the date and time for which all user's passwords expire for a particular site."
msgTitle = "Globalscape EFT Server"
serverMessage = "Enter EFT Server IP..."
portMessage = "Enter EFT Server Port..."
adminMessage = "Enter EFT Admin username..."
passMessage = "Enter EFT Admin password..."
siteMessage = "Enter the site name..."
txtMyOutputFileName = "EFT-PasswordExpirations.csv"

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

Set myFSO = CreateObject("Scripting.FileSystemObject")
Set WriteStuff = myFSO.OpenTextFile(txtMyOutputFileName, 8, True)

set theSite = Nothing
set sites = SFTPServer.Sites()
For i = 0 to SFTPServer.Sites.Count-1
   set theSite=Sites.Item(i)
   if LCase(Trim(theSite.Name)) = LCase(Trim(siteName)) then
      WriteStuff.WriteLine("Users password expiration for " & theSite.Name & ":")
	  WriteStuff.WriteLine("Username,Password Expiration date")
      arUsers = theSite.GetUsers()
      For j = LBound(arUsers) to UBound(arUsers)
         set userSettings = theSite.GetUserSettings(arUsers(j))
			If userSettings.IsPasswordAgeLimited(pDate) Then
				dtAccPssExp = Cstr(pDate)
				Else
				dtAccPssExp = "Does not expire"
			End If
         WriteStuff.WriteLine(arUsers(j) & ", " & dtAccPssExp)
      Next
   end if
Next

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