'
' FILE: EFTImport.vbs
' CREATED: 10 JAN 2008 GTH/ PPK
' MODIFIED:  7 JUL 2011 ALA
' PURPOSE: To import EFT VFS permissions from text file 

Option Explicit
Dim oArgs
Dim strHost, strLogin, strPassword, strTextFile, strSite, strPort
Dim oSFTPServer, oSites, oSite, oPerm
Dim aSiteGroups, aSiteUsers, strGroupList, strUserList, strUsersAndGroups
Dim g_arrFileLines()

Class CPermission
	Private m_sPermissionGroup
	Private m_sPermissionString
	Private m_sInheritedFrom

	'File permissions
	Private m_sFileUpload
	Private m_sFileDownload
	Private m_sFileAppend
	Private m_sFileDelete
	Private m_sFileRename
	Private m_sDirList
	'Folder permissions
	Private m_sDirShowInList
	Private m_sDirCreate
	Private m_sDirDelete
	'Contents
	Private m_sDirShowReadOnly
	Private m_sDirShowHidden

	Public Property Get PermissionGroup()
		PermissionGroup = m_sPermissionGroup
	End Property
	Public Property Let PermissionGroup(value)
		m_sPermissionGroup = value
	End Property

	Public Property Get PermissionString()
		PermissionString = m_sPermissionString
	End Property
	Public Property Let PermissionString(value)
		m_sPermissionString = value
	End Property

	Public Property Get InheritedFrom()
		InheritedFrom = m_sInheritedFrom
	End Property
	Public Property Let InheritedFrom(value)
		m_sInheritedFrom = value
	End Property

	'File permissions
	Public Property Get FileUpload()
		FileUpload = m_sFileUpload
	End Property
	Public Property Let FileUpload(value)
		m_sFileUpload = value
	End Property

	Public Property Get FileDownload()
		FileDownload = m_sFileDownload
	End Property
	Public Property Let FileDownload(value)
		m_sFileDownload=value
	End Property

	Public Property Get FileAppend()
		FileAppend = m_sFileAppend
	End Property
	Public Property Let FileAppend(value)
		m_sFileAppend=value
	End Property

	Public Property Get FileRename()
		FileRename = m_sFileRename
	End Property
	Public Property Let FileRename(value)
		m_sFileRename=value
	End Property

	Public Property Get DirList()
		DirList = m_sDirList
	End Property
	Public Property Let DirList(value)
		m_sDirList=value
	End Property

	Public Property Get FileDelete()
		FileDelete = m_sFileDelete
	End Property
	Public Property Let FileDelete(value)
		m_sFileDelete=value
	End Property

	'Folder permissions
	Public Property Get DirShowinList()
		DirShowinList = m_sDirShowinList
	End Property
	Public Property Let DirShowinList(value)
		m_sDirShowinList=value
	End Property

	Public Property Get DirCreate()
		DirCreate = m_sDirCreate
	End Property
	Public Property Let DirCreate(value)
		m_sDirCreate=value
	End Property

	Public Property Get DirDelete()
		DirDelete = m_sDirDelete
	End Property
	Public Property Let DirDelete(value)
		m_sDirDelete=value
	End Property

	'Content permissions
	Public Property Get DirShowHidden()
		DirShowHidden = m_sDirShowHidden
	End Property
	Public Property Let DirShowHidden(value)
		m_sDirShowHidden=value
	End Property

	Public Property Get DirShowReadonly()
		DirShowReadonly = m_sDirShowReadonly
	End Property
	Public Property Let DirShowReadonly(value)
		m_sDirShowReadonly=value
	End Property
End Class

	'==============================================================================
	'
	' Main
	'
	'==============================================================================
	'Comment this next line if you want to use arguments passed to the script
	If (ProcessArgs=-1) then wscript.quit

	'Un-comment if you want to hardcode the variable info
	REM strHost = "localhost"
	REM strLogin = "test"
	REM strPassword= "test"
	REM strTextFile = "output.txt"
	REM strSite= "MySite"
	REM strPort="1100"

WScript.Echo  "Runtime Parameters:" & vbCrLf & "-------------------" & vbCrLf & _
             "strHost = " & strHost & vbCrLf & _
			 "strPort = " & strPort & vbCrLf & _
             "Login   = " & strLogin & vbCrLf & _
             "Password= " & strPassword & vbCrLf & _
			 "strSite = " & strSite & vbCrLf & _
             "strTextFile = " & strTextFile & vbCrLf

	 
Call ConnectAndLogin()
Call ReadVFSData()
Call RetrieveUsersAndGroups()
Call ImportVFSData()
'==============================================================================
' This method connectst to the specified EFT server and attempts to
' log in using the supplied information.
'==============================================================================
Sub ConnectAndLogIn()
	Dim WshShell
	' Let's check to be sure we can connect to the specified EFT Server:
	WScript.Echo "<CONNECTING TO SERVER>"
	WScript.Echo Chr(9) & "Connecting to " & strLogin & "@" & strHost & ":1100 [Site " & strSite & "]"
	Set oSFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")
	' NOTE we assume default ADMIN port of 1100 -- please chang this if you have
	' manually configured your EFT to be different.
	On Error Resume Next
	oSFTPServer.Connect strHost, CLng(strPort), strLogin, strPassword

	If Err.Number <> 0 Then
		WScript.Echo Chr(9) & "Error connecting to '" & strHost & ":" & 1100 & "' -- " & err.Description & " [" & CStr(err.Number) & "]", vbInformation, "Error"
		WScript.Echo Chr(9) & "Attempting to restart service..."
		err.Clear
		Set WshShell = WScript.CreateObject("WScript.Shell")
		call WshShell.Run("net start ""globalscape eft server""", 1, true)
		Set WshShell = nothing
		WScript.Echo Chr(9) & "Waiting for 5 seconds for the service to initiate..."
		WScript.Sleep 5000
		WScript.Echo Chr(9) & "Connecting to " & strLogin & "@" & strHost & ":1100 [Site " & strSite & "]"
		    oSFTPServer.Connect strHost, CLng(strPort), strLogin, strPassword
		If Err.Number <> 0 Then
			WScript.Echo Chr(9) & "Error connecting to '" & strHost & ":" & 1100 & "' -- " & err.Description & " [" & CStr(err.Number) & "]", vbInformation, "Error"
			WScript.Quit 253
		Else
			WScript.Echo Chr(9) & "Connected to " & strHost
		end if
	End If
	On Error GoTo 0  ' resume error trapping
	set oSites=oSFTPServer.Sites
	Dim iCount	
	For iCount=0 to oSites.count - 1
		Set oSite = oSites.Item(iCount)
		if LCase(Trim(oSite.Name)) = LCase(Trim(strSite)) then
			exit for
		End if
	Next	
	WScript.Echo Chr(9) & "Connected to site '" & oSite.Name & "'" & vbCrLf

End Sub

'==============================================================================
'
'   ProcessArgs
'
'   Parse the command-line arguments.  Results are set in global variables
'    (strHost, strLogin, strPassword, strTextFile, strSite, strPort ).
'
'==============================================================================
public function ProcessArgs
    Dim iCount
    Dim oArgs
    on error resume next
	' Default our arguments.  Some are required.
	strHost = ""
	strLogin = ""
	strPassword = ""
	strPort = "1100"
	strSite = ""
	strTextFile=""
    ' Get the command-line arguments
    '
    Set oArgs = WScript.Arguments
    if oArgs.Count > 0 then
		' We have command-line arguments.  Loop through them.
		iCount = 0
		ProcessArgs = 0

		do while iCount < oArgs.Count

			select case oArgs.Item(iCount)
				'
				' Server name argument
				'
				case "-s"
					if( iCount + 1 >= oArgs.Count ) then
						Syntax
						ProcessArgs = -1
						exit do
					end if

					strHost = oArgs.Item(iCount+1)
					iCount = iCount + 2

				'
				' What port to connect to for EFT server. Default to 1100
				'
				case "-port"
					if( iCount + 1 >= oArgs.Count ) then
						Syntax
						ProcessArgs = -1
						exit do
					end if

					strPort = oArgs.Item(iCount+1)
					iCount = iCount + 2

				'
				' admin login name argument
				'
				case "-u"
					if( iCount + 1 >= oArgs.Count ) then
						Syntax
						ProcessArgs = -1
						exit do
					end if

					strLogin = oArgs.Item(iCount+1)
					iCount = iCount + 2

				'
				' admin password argument
				'
				case "-p"
					if( iCount + 1 >= oArgs.Count ) then
						Syntax
						ProcessArgs = -1
						exit do
					end if

					strPassword = oArgs.Item(iCount+1)
					iCount = iCount + 2

				'
				' Which site to look into.  Defaults into 1.
				'
				case "-site"
					if( iCount + 1 >= oArgs.Count ) then
						Syntax
						ProcessArgs = -1
						exit do
					end if

					strSite = oArgs.Item(iCount+1)
					iCount = iCount + 2

				'
				' CSVFile name argument
				'
				case "-f"
					if( iCount + 1 >= oArgs.Count ) then
						Syntax
						ProcessArgs = -1
						exit do
					end if

					strTextFile = oArgs.Item(iCount+1)
					iCount = iCount + 2
				'
				' Help option
				'
				case "-?"
					Syntax
					ProcessArgs = -1
					exit function
				'
				' Invalid argument
				'
				case else
				' Display the syntax and return an error
					wscript.echo "### ERROR: UNKNOWN ARGUMENT " & oArgs.Item(iCount) & vbCrLf
					Syntax
					ProcessArgs = -1
					Exit function
			end select
		loop
	Else
		'
		' There were no command-line arguments, display the syntax
		' and return an error.
		'
		Syntax
		ProcessArgs = -1
	End if

	Set oArgs = Nothing

	If ( strHost = "" OR strLogin = "" or strSite = "" or strPassword = "" or strTextFile = "" ) Then
	WScript.Echo  "### ERROR : MISSING PARAMETERS" & vbCrLf & "-------------------" & vbCrLf & _
             "strHost = " & strHost & vbCrLf & _
			 "strPort = " & strPort & vbCrLf & _
             "Login   = " & strLogin & vbCrLf & _
             "Password= " & strPassword & vbCrLf & _
			 "strSite = " & strSite & vbCrLf & _
             "strTextFile = " & strTextFile & vbCrLf

		Syntax
		ProcessArgs = -1
	End If

End function ' ProcessArgs

'Parse the permission string, e.g. UDADRSCDLHO etc., and create an object of CPermission class.
'This is to make the easier handling of permissions.
Public Function ParsePermissionString(sPermissionGroup, sPermissionString, sInheritedFrom)
	Set oPerm = New CPermission
	oPerm.PermissionGroup	= sPermissionGroup
	oPerm.InheritedFrom		= sInheritedFrom
	oPerm.PermissionString	= UCase(Trim(sPermissionString))
	sPermissionString		= UCase(Trim(sPermissionString))

	'File Permissions
	oPerm.FileUpload		= IIf( Mid(sPermissionString,1,1) = "U", True, False)	'File Upload
	oPerm.FileDownload		= IIf( Mid(sPermissionString,2,1) = "D", True, False)	'File Download
	oPerm.FileAppend		= IIf( Mid(sPermissionString,3,1) = "A", True, False)	'File Append
	oPerm.FileDelete		= IIf( Mid(sPermissionString,4,1) = "D", True, False)	'File Delete
	oPerm.FileRename		= IIf( Mid(sPermissionString,5,1) = "R", True, False)	'File Rename
	oPerm.DirShowinList		= IIf( Mid(sPermissionString,6,1) = "S", True, False)	'Dir Show in list
	oPerm.DirCreate			= IIf( Mid(sPermissionString,7,1) = "C", True, False)	'Dir Create
	oPerm.DirDelete			= IIf( Mid(sPermissionString,8,1) = "D", True, False)	'Dir Delete

	oPerm.DirList			= IIf( Mid(sPermissionString,9,1) = "L", True, False)	'File List
	oPerm.DirShowHidden		= IIf( Mid(sPermissionString,10,1)= "H", True, False)	'content Show hidden
	oPerm.DirShowReadOnly	= IIf( Mid(sPermissionString,11,1)= "O", True, False)	'Cotent Show Readonly

	'Return the CPermission object
	Set ParsePermissionString=oPerm
End Function

'Updates the folder permission using SFTPCOMInterface's "SetPermissions" method
Function UpdateFolderPermissions(oPerm, sFolderName)
	On Error resume next
		Dim oFolderPerm
		'Getting permissions for the folder and also verifying that it can get the Group object
		Set oFolderPerm = oSite.GetBlankPermission(sFolderName, oPerm.PermissionGroup)
			if oFolderPerm then 
			oFolderPerm.FileUpload		= oPerm.FileUpload
			oFolderPerm.FileDownload	= oPerm.FileDownload
			oFolderPerm.FileDelete		= oPerm.FileDelete
			oFolderPerm.FileRename		= oPerm.FileRename
			oFolderPerm.FileAppend		= oPerm.FileAppend
			oFolderPerm.DirCreate		= oPerm.DirCreate
			oFolderPerm.DirDelete		= oPerm.DirDelete
			oFolderPerm.DirList			= oPerm.DirList
			oFolderPerm.DirShowInList	= oPerm.DirShowInList
			oFolderPerm.DirShowHidden	= oPerm.DirShowHidden
			oFolderPerm.DirShowReadOnly = oPerm.DirShowReadOnly
			
			Call oSite.SetPermission(oFolderPerm, false)
			oSFTPServer.ApplyChanges
			
			UpdateFolderPermissions = true
			else
				Wscript.Echo "ERROR: Permissions import failed for folder: " &  sFolderName  & "."
				Wscript.Echo "ERROR: Verify that folder and group '" & oPerm.PermissionGroup & "' exists in new site."
		end if 
	Set oPerm = Nothing
End Function

'Obtain list of permission groups and create single string for validating later (ala: 7/7/2011)
Sub RetrieveUsersAndGroups()
	Dim SiteGrp
	Dim SiteUser
	aSiteGroups = oSite.GetPermissionGroups
	aSiteUsers = oSite.GetUsers()
	strGroupList = ""
	strUserList = ""
	For Each SiteGrp in aSiteGroups
		strGroupList = strGroupList & SiteGrp & vbCrLf
	Next
	For Each SiteUser in aSiteUsers
		strUserList = strUserList & SiteUser & vbCrLf
	Next
	strUsersAndGroups = strGroupList & strUserList
	'WScript.Echo "DEBUG: strUsersAndGroups = " & strUsersAndGroups
End Sub

Sub ImportVFSData()
	Dim i,j,iPos,arLine,iPosg
	Dim strFolder,strGroupName,strPermissions,strInheritFromFolder, strVirtulPath, strRealPath
	WScript.Echo "INFO: Importing VFS data started ...."& VBcrlf
		For i = Lbound(g_arrFileLines) to UBound(g_arrFileLines)-1
			arLine = Split(g_arrFileLines(i),",")
			strFolder = arLine(0)
			'WScript.Echo "DEBUG: strFolder = " & strFolder
			strGroupName = arLine(1)
			'WScript.Echo "DEBUG: strGroupName = " & strGroupName
			strPermissions = arLine(2)
			'WScript.Echo "DEBUG: strPermissions = " & strPermissions
			strInheritFromFolder = arLine(3)
			'WScript.Echo "DEBUG: strInheritFromFolder = " & strInheritFromFolder
			'Verify that the group is valid (ala: 7/7/2011)
			iPosg = InStr(1, strUsersAndGroups, strGroupName, 1)
			'WScript.Echo "DEBUG: iPosg = " & iPosg
			If ( iPosg > 0) Then
				iPosg = 0
				'fixed echo string. folder and group are now enumerated.
				WScript.Echo "INFO: Importing VFS data for folder '" & strFolder & "' for Group '" & strGroupName & "'"
				iPos = InStr(1, strFolder, " - Virtual", 1 )
				If ( iPos > 0 ) Then
					WScript.Echo "INFO: -->Stripping VIRTUAL portion of folder name" & strFolder
					strVirtulPath = Left( strFolder, iPos -1 ) & "/"
					iPos = InStr(1, strFolder, "(", 1 )
					if( iPos > 0 ) Then
						strRealPath   = Mid(strFolder,iPos+1, len(strFolder)- (iPos + 2)) 
					'Now we have virtual name and real path ..Try to create virtual  folder on site 
					'If it fails, just move on to the next step which is setting permissions.  We're assuming it's failing because the virtual folder already exists.
					On Error Resume Next
						call oSite.CreateVirtualFolder(strVirtulPath, strRealPath)
					end if 
					strFolder = strVirtulPath 'assign correct folder name to update permissions
				End If
				if(strGroupName <> "") Then ' if no permission, means we are working with virtual folder which has inherited permissions, so we only need to create the folder.
					Call ParsePermissionString(strGroupName,strPermissions,strInheritFromFolder)
					Call UpdateFolderPermissions(oPerm,strFolder)
				End if
			End if
			WScript.Sleep(30)
		Next  
	WScript.Echo "INFO: VFS Data import complete."& VBcrlf
End Sub

Sub  ReadVFSData()
	Dim i: i = 0
	Dim oFSO, oFile
	Set oFSO = CreateObject("Scripting.FileSystemObject")
	Set oFile = oFSO.OpenTextFile(strTextFile, 1 ) 
	Do Until oFile.AtEndOfStream 
	Redim Preserve g_arrFileLines(i) 
	g_arrFileLines(i) = oFile.ReadLine 
	i = i + 1 
	Loop 
	oFile.Close
End Sub

'Checks whether the folder has subfolder or not.
'If the  folder has "" appended to it then it contains the sub folder

function hasSubFolders(ByVal sFolderName)
	if sFolderName <> "" then
		if Right(sFolderName, 1) = """" then
			hasSubFolders = true
		end if
	end if
End function

'User-defined IIf function to perform ternary operation i.e. expression? true_value : false_value
Function IIf(bCondition, sTrueValue, sFalseValue)
	if bCondition Then
		If IsObject(sTrueValue) Then
			Set IIf = sTrueValue
		Else
			IIf = sTrueValue
		End If
	Else
		If IsObject(sFalseValue) Then
			Set IIf = sFalseValue
		Else
			IIf = sFalseValue
		End If
	End If
End Function

'==============================================================================
'   Syntax
'   Show the command-line syntax
'==============================================================================
public function Syntax
	wscript.echo  "Purpose:   Import VFS tree permissions from a text file " & vbCrLf & _
		"Usage:     " & wscript.scriptname & " <arguments>" & vbCrLf & _
		"Required Arguments:" & vbCrLf & _
		"     -s     EFT Server" & vbCrLf & _
		"     -u     Admin username for EFT Server" & vbCrLf & _
		"     -p     Admin password" & vbCrLf & _
		"     -site  Site name on the server we are manipulating. Defaults to first site" & vbCrLf & _
		"     -f     Path of text file to retrieve data " & vbCrLf & _
		vbCrLf & _
		"Optional Arguments: " & vbCrLf & _
		"     -?     This help" & vbCrLf & _
		"     -port  Admin port on EFT server. Defaults to 1100" & vbCrLf & _
		"Example:   " & wscript.scriptname & "  -s localhost -port 1100 -u admin -p secret -site SiteName -f c:\migrate.txt" 

end function    ' Syntax

