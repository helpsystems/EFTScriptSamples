'
' FILE: ListUserInfo.vbs
' CREATED: 6-8-2012 (dransom@globalscape.com)
' UPDATED: 6-5-2014 (jhulme@globalscape.com)
' VERSION: 1.1 *added Settings template membership | Test against 6.5.x
' PURPOSE: Modified script that creates CSV file for users
' Tested against EFT Server Versions 6.3.x / 6.4.x / 6.5.x
' Provides the following information: 
' 	Username, Description, Email,Account Creation, Disk Quota, Used space, Home Directory, Settings template membership, Last Connection Time
' **This script is provided AS IS to our customers as a courtesy no support is provided in modifying or debugging this script.
' 
'
Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")
CRLF = (Chr(13)& Chr(10))
'Modify the following variables to match your environment
   txtServer = "localhost"
   txtPort =  "1100"
   txtUserName = "eftadmin"
   txtPassword = "a"
   txtSiteName = "GS"
   txtMyOutputFileName = "EFT-Users.csv"

SFTPServer.Connect txtServer, txtPort, txtUserName, txtPassword
If Err.Number <> 0 Then
   WScript.Echo "Error connecting to '" & txtServer & ":" & txtPort & "' -- " & err.Description & " [" & CStr(err.Number) & "]", vbInformation, "Error"
   WScript.Quite(255)
Else
   WScript.Echo "Connected to " & txtServer
End If
set Sites=SFTPServer.Sites

'open output file
Set myFSO = CreateObject("Scripting.FileSystemObject")
Set WriteStuff = myFSO.OpenTextFile(txtMyOutputFileName, 8, True)

'write data to a file
For i = 0 to SFTPServer.Sites.Count-1
   set theSite=Sites.Item(i)
   if LCase(Trim(theSite.Name)) = LCase(Trim(txtSiteName)) then
      WriteStuff.WriteLine("Users for " & theSite.Name & ":")
	  WriteStuff.WriteLine("Username,Description,Email,Account Creation, Disk Quota, Used space, Home Directory, Settings Template, Last Connection Time, Enabled")
      arUsers = theSite.GetUsers()
      For j = LBound(arUsers) to UBound(arUsers)
         set userSettings = theSite.GetUserSettings(arUsers(j))
         WriteStuff.WriteLine(arUsers(j) & ", " & userSettings.GetDescription & ", " & userSettings.Email & ", " & userSettings.AccountCreationTime  & ", " & userSettings.GetMaxSpace  & ", " & userSettings.GetUsedSpace  & ", " & userSettings.GetHomeDirString & ", " & theSite.GetUserSettingsLevel(arUsers(j)) & ", " & userSettings.LastConnectionTime & ", " & userSettings.GetEnableAccount)
      Next
   end if
Next

'Close all variables
WriteStuff.Close
SFTPServer.Close
Set theSite = nothing
Set SFTPServer = nothing
SET WriteStuff = NOTHING
SET myFSO = NOTHING