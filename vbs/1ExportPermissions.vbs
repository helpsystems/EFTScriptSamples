'FILENAME:	 	ExportVirtualPermissions.vbs
'DATE:	 		1 JUL 2011
'PROGRAMMER:	A. ACUNA
'USE:			Use this to export all the permissions in a site.
'**** run cmd "cscript (script location) > (location of output txt document)****


'Create GlobalSCAPE object
Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

Dim strHost, strLogin, strPassword, strTextFile, strSite, strPort
Dim oSFTPServer, oSites, oSite
CRLF = (Chr(13)& Chr(10))

'Comment this next line if you want to use arguments passed to the script
If (ProcessArgs=-1) then wscript.quit

'Un-comment if you want to hardcode the variable info
	REM strHost = "192.168.102.143"
	REM strPort =  "1100"
	REM strLogin = "test"
	REM strPassword = "test"
	REM strTextFile = "output.txt"
	REM strSite = "MySite"
	 
	 
 WScript.Echo  "Runtime Parameters:" & vbCrLf & "-------------------" & vbCrLf & _
		 "strHost = " & strHost & vbCrLf & _
		 "strPort = " & strPort & vbCrLf & _
		 "Login   = " & strLogin & vbCrLf & _
		 "Password= " & strPassword & vbCrLf & _
		 "strSite = " & strSite & vbCrLf & _
		 "strTextFile = " & strTextFile & vbCrLf 
		 
'Get File Object
Set objFSO = CreateObject("Scripting.FileSystemObject")

'Create/overwrite log file
Set objLogFile = objFSO.CreateTextFile(strTextFile, True)

Call ConnectAndLogin()

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
		call WshShell.Run("net start ""eft server""", 1, true)
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
'   (strHost, strLogin, strPassword, strTextFile, strSite, strPort ).
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
					wscript.echo "Unknown argument: " & oArgs.Item(iCount) & vbCrLf
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
		Syntax
		ProcessArgs = -1
	End If

End function ' ProcessArgs

REM Start code here
g_strVFSBuffer= ""	

'Retrieve all the paths that have permissions in the config and decorate the orphans with a *
arVFolders = oSite.GetPermPathsList("-do")

'Uncomment this next line to show the folder list for debug only
'objLogFile.WriteLine(arVFolders)

'Break down the return string by its delimiter CRLF
arVFolders = Split(arVFolders, CRLF)
For Each fl in arVFolders
	sPath = fl
	If Not IsOrphan(spath) Then
		WScript.Echo "Getting permissions for path: " & fl
		On Error Resume Next
		'WScript.Echo "Calling GetFolderPerms "
		pFolder = oSite.GetFolderPermissions(sPath)
		'Check to see if there was an error getting the permissions.  If so, we don't want to write this to path to file.
		If Not Err.Number <> 0 Then
			'WScript.Echo "Calling StorePermissions "
			Call StorePermissions(pFolder,sPath)
			Err.Number = 0
		Else 
			WScript.Echo "Error when checking folder: " & fl
			WScript.Echo "Error Description:  " & Err.Number & ":  " & Err.Description
		End If
	End If
Next 

SFTPServer.Close
Set SFTPServer = nothing


'Function used to determine if the returned path is an orphan in the VFS.  
Function IsOrphan(chkpath)
	IsOrphan = False
	If Right(chkpath,1) = "*" then
		IsOrphan = True
	End If
End Function

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

Function StripVirtualPortion(ByVal sPath)
	
	Dim iPos , sVirtualFolderPath,bIsVirtual
	
	iPos = InStr(1, sPath, " - Virtual", 1 )
	If ( iPos > 0 ) Then
		WScript.Echo "-->Stripping VIRTUAL portion of folder name"
		sVirtualFolderPath = sPath
		sPath = Left( sPath, iPos -1 ) & "/"
	End If
	
	StripVirtualPortion = sPath
End Function

function StorePermissions(arPerms, strFullFolderPath)
	Dim iCount, oPermission
	sPath = StripVirtualPortion(strFullFolderPath)
        If sPath = "" Or Right(sPath, 1) <> "/" Then
		sPath = sPath & "/"
	End If

	'WScript.Echo "Begin StorePerimssions: Exporting data for folder " & strFullFolderPath
	'WScript.Echo "Looping through permissions..."
	For iCount = LBound(arPerms) To UBound(arPerms)
		Set oPermission = arPerms (iCount)
		'WScript.Echo "DEBUG: Checking path...  " & sPath
		'WScript.Echo "DEBUG: Value of oPermission.InheritedFrom = " & oPermission.InheritedFrom
		'If the current folder is the root folder Or
		'If the folder path length matches that of the "inherited from" path 
		'(means that personal permissions are set on the folder for this group and inherit status is not set)
		If  (sPath = "/" Or (Len(sPath) = Len(oPermission.InheritedFrom)))  then
			'WScript.Echo "DEBUG:  First If has been matched "
			'Append permissions group name
			g_sOutPut = g_sOutPut & strFullFolderPath & ","
			g_sOutPut =  g_sOutPut & oPermission.Client & ","
			
			'Append folder permissions
			g_sOutPut =  g_sOutPut & IIf(oPermission.FileUpload,	"U", "-")
			g_sOutPut =  g_sOutPut & IIf(oPermission.FileDownload,	"D", "-")
			g_sOutPut =  g_sOutPut & IIf(oPermission.FileAppend,	"A", "-")
			g_sOutPut =  g_sOutPut & IIf(oPermission.FileDelete,	"D", "-")
			g_sOutPut =  g_sOutPut & IIf(oPermission.FileRename,	"R", "-")
			g_sOutPut =  g_sOutPut & IIf(oPermission.DirShowinList, "S", "-")
			g_sOutPut =  g_sOutPut & IIf(oPermission.DirCreate,		"C", "-")
			g_sOutPut =  g_sOutPut & IIf(oPermission.DirDelete,		"D", "-")
			g_sOutPut =  g_sOutPut & IIf(oPermission.DirList,		"L", "-")
			g_sOutPut =  g_sOutPut & IIf(oPermission.DirShowHidden,	"H", "-")
			g_sOutPut =  g_sOutPut & IIf(oPermission.DirShowReadOnly,"O", "-")
			g_sOutPut =  g_sOutPut & ","

			'Append "Inherited from" foldername
			g_sOutPut =  g_sOutPut & IIf(oPermission.Folder = "", "/", oPermission.Folder)

			WScript.Echo g_sOutPut
			g_strVFSBuffer = g_strVFSBuffer & g_sOutPut
			objLogFile.WriteLine(g_strVFSBuffer)
			g_strVFSBuffer = ""
			g_sOutPut = ""
			
			
		Else
			'In case of virtual folder with inheritance set to true, then
			'the above logic fails to make an entry into the back up permissions file
			'so handle the virtual folder case here
			'WScript.Echo "Else has been matched "
			'If the folder is a virtual folder and if the folder entry is not found in the global buffer
			If InStr(1,strFullFolderPath, "- Virtual", 1 ) > 0 And InStr (1, g_strVFSBuffer, strFullFolderPath, 1) = 0 Then	
				WScript.Echo "Found a virtual folder " + strFullFolderPath + " with inherited group permission. Adding a blank entry"
				g_strVFSBuffer = g_strVFSBuffer & strFullFolderPath &",,,"
				objLogFile.WriteLine(g_strVFSBuffer)
				g_strVFSBuffer = ""
			End If

		End If
	Next 
end function

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



'==============================================================================
'   Syntax
'   Show the command-line syntax
'==============================================================================
public function Syntax
	wscript.echo    vbCrLf & _
		"Purpose:   Export VFS tree permissions to a text file " & vbCrLf & _
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