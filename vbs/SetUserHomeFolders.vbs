'
' FILE: SetUserHomeFolders.vbs
' Modified: 6-04-2014 (dransom@globalscape.com)
' PURPOSE: Modified script that will set a user's home folder.
' Required parameters:  SetUserHomeFolder.vbs <username> <VFS Home Folder>
' Example:  SetUserHomeFolder.vbs dransom "/usr/dransom"
'
Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")
CRLF = (Chr(13)& Chr(10))
'Modify the following variables to match your environment
   txtServer = "localhost"
   txtPort =  "1100"
   txtUserName = "test"
   txtPassword = "test"
   txtSiteName = "MySite"

SFTPServer.Connect txtServer, txtPort, txtUserName, txtPassword
If Err.Number <> 0 Then
   WScript.Echo "Error connecting to '" & txtServer & ":" & txtPort & "' -- " & err.Description & " [" & CStr(err.Number) & "]", vbInformation, "Error"
   WScript.Quite(255)
Else
   WScript.Echo "Connected to " & txtServer
End If
set Sites=SFTPServer.Sites

txtEFTUser = WScript.Arguments.Item(0)
txtHomeFolder = WScript.Arguments.Item(1)


For i = 0 to SFTPServer.Sites.Count-1
   set theSite=Sites.Item(i)
   if LCase(Trim(theSite.Name)) = LCase(Trim(txtSiteName)) then
      set userSettings = theSite.GetUserSettings(txtEFTUser)
		 userSettings.setHomeDirIsRoot(1)
		 userSettings.SetHomeDir(1)
         userSettings.SetHomeDirString(txtHomeFolder)
		 Set oFolderPerm = theSite.GetBlankPermission(txtHomeFolder, txtEFTUser)
				oFolderPerm.FileUpload		= TRUE
				oFolderPerm.FileDownload	= TRUE
				oFolderPerm.FileDelete		= TRUE
				oFolderPerm.FileRename		= TRUE
				oFolderPerm.FileAppend		= TRUE
				oFolderPerm.DirCreate		= TRUE
				oFolderPerm.DirDelete		= TRUE
				oFolderPerm.DirList			= TRUE
				oFolderPerm.DirShowInList	= TRUE
				oFolderPerm.DirShowHidden	= TRUE
				oFolderPerm.DirShowReadOnly = TRUE
			Call theSite.SetPermission(oFolderPerm, false)
   end if
Next

'Close all variables
SFTPServer.Close
Set theSite = nothing
Set SFTPServer = nothing
