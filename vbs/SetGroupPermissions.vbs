'
' FILE: ExportUsersAndGroupMembership.vbs
' AUTHOR: Brian Arriaga
' CREATED: 9 JAN 2015
' MODIFIED:  9 JAN 2015
' ORIGINALLY CREATED FOR: EFT Server 6.5-7.0.3
' PURPOSE: This script loops through all Users of a specified site and performs the GetPermissionGroupsOfUser() COM API method along with 
' objLogFile.WriteLine() to record the data in "username,group" format to an output file
' The output text file can be used with ImportUsersAndGroupMembership.vbs to import the user+group memberships. 
' Can be used to backup group memberships in scenarios were Group membership settings are being lost.
' 
' NOTE: The creation and modification of COM API scripts is not within the standard scope of Support.
' All COM API scripts are supplied as a courtesy "AS IS" with no implied or explicit guarantee of function.
' GlobalSCAPE is not responsible for any damage to system or data as a result of using supplied COM API scripts.
' Further information and usage instruction on COM API methods can be found online within the help file: http://help.globalscape.com/help/
'

Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")


'Modify the below connection details to reflect your own environment.
   txtServer = "localhost"
   txtPort =  "1100"
   txtAdminUserName = "eftadmin"
   txtAdminPassword = "a"
   txtSiteName = "GS"
   
'Folder to apply group/user permissions to
   txtVFSName = "/usr/grouptesting"
   
'Group to add to folder
   txtGroup = "testGroup"
   
'The below values specify each permission and whether or not the client has it
   boolDirCreate = True
   boolDirDelete = False
   boolDirList = True
   boolDirShowHidden = False
   boolDirShowInList = True
   boolDirShowReadOnly = False
   boolFileAppend = True
   boolFileDelete = False
   boolFileDownload = True
   boolFileRename = False
   boolFileUpload = True
   
Dim theSite
g_strBuffer =""

Call ConnectToServer()
Call FindSite()
Call ListUsersAndGroups()


'==========================================
'This sub connects to the server
'=========================================
Sub ConnectToServer()
	SFTPServer.Connect txtServer, txtPort, txtAdminUserName, txtAdminPassword

End Sub


'==========================================
'This sub finds the specified site
'=========================================
Sub FindSite()	
	set Sites=SFTPServer.Sites

	For i = 0 to SFTPServer.Sites.Count-1
	   set theSite=Sites.Item(i)
	   if LCase(Trim(theSite.Name)) = LCase(Trim(txtSiteName)) then
			exit for
		End if
	Next	
End Sub
	
	
'==========================================
'This Sub adds specified group/user to specified VFS folder
'=========================================	
Sub ListUsersAndGroups()
	set oPerm = theSite.GetBlankPermission(txtVFSName, txtGroup)
	oPerm.DirCreate = boolDirCreate
   oPerm.DirDelete = boolDirDelete
   oPerm.DirList = boolDirList
   oPerm.DirShowHidden = boolDirShowHidden
   oPerm.DirShowInList = boolDirShowInList
   oPerm.DirShowReadOnly = boolDirShowReadOnly
   oPerm.FileAppend = boolFileAppend
   oPerm.FileDelete = boolFileDelete
   oPerm.FileDownload = boolFileDownload
   oPerm.FileRename = boolFileRename
   oPerm.FileUpload = boolFileUpload
   
   theSite.SetPermission(oPerm)
   
End Sub

SFTPServer.Close
Set SFTPServer = nothing