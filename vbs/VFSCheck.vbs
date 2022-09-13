'This script is provided AS IS.  Back up Server configuration before attempting to run.
'FILENAME:	 	VFSCheck.vbs
'DATE:	 		31 JAN 2012
'USE:			This will list all the folders of a site and display their corresponding physical paths. 
'Notes:			There is some logic for error checking, but I never got it to work correctly
'				There is additional logic that will delete folders from VFS if they do not have a matching Physical path.
'**** run cmd "cscript (script location)****
'Modify the section "CONSTANTS/PARAMETERS

Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

'Get File Object
Set objFSO = CreateObject("Scripting.FileSystemObject")  'Output file Object
Set objFSO2 = CreateObject("Scripting.FileSystemObject") 'Check foler existince object
Set objFSO3 = CreateObject("Scripting.FileSystemObject") 'Error Log

'Create/overwrite log file
Set objLogFile = objFSO.CreateTextFile("virtual_folders.txt", True)
'Set objErrorLogFile = objFSO3.CreateTextFile("virtual_folders_errors.log", True)

'On Error Resume Next 'Added Error Capture instructions for some steps beyond this point.

'CONSTANTS/PARAMETERS:
txtServer = "localhost"
txtPort =  "1100"
txtAdminUserName = "test"
txtPassword = "test"
txtSiteName = "MySite"
'***WARNING BACKUP CONFIG FILES BEFORE MODIFYING THE NEXT LINE!!
delFlag="False" 'Set to True to actually delete the VFS entry from EFT. ***WARNING BACKUP CONFIG FILES BEFORE DOING THIS!!

objLogFile.WriteLine("VFS Path, Physical Path, Folder Status")
'objErrorLogFile.WriteLine("Folder, Error, Hex, Source, Description")

If Not Connect(txtServer, txtPort, txtAdminUserName, txtPassword) Then
  WScript.Quit(0)
End If

set Sites=SFTPServer.Sites 
SitesTotal = Sites.count
For iCount=0 to Sites.count - 1
	Set Site = Sites.Item(iCount)
	if LCase(Trim(Site.Name)) = LCase(Trim(txtSiteName)) then
		exit for
	End if
Next

'The following step was used for debugging.
'Msgbox Site.GetRootFolder()

'This step kicks off the whole process.  I used "" as the root since the recursion logic adds the / to the path.
GetNextFolder "", Site

WScript.Echo "Done"

SFTPServer.Close
Set SFTPServer = nothing

Function GetNextFolder (CurrFolder,objSite)
	CurrFolder = CurrFolder & "/"
	folderList = objSite.GetFolderList(CurrFolder)
	if Err.Number <> 0 Then
		objLogFile.WriteLine(CurrFolder & ", " & ", ERROR-FOLDER NOT FOUND IN VFS")
		DisplayErrorInfo CurrFolder
	else
		arVFolders = Split(folderlist, CRLF)
		recurseFlag=0
		For Each fl in arVFolders
			WScript.Echo "Exporting info for folder:  " & CurrFolder & fl
			'if the folder name has " at the end of it there are additional folders and we need to recurse to next level
			if instr(fl,chr(34)) > 0 then
				'strip " from the folder path
				fl = Left(fl,len(fl)-1)
				'set flag to recurse
				recurseFlag=1
			End if
			'strip of the EFT Virtual informaiton
			f2 = fl
			fl = StripVirtualPortion(fl)
			'WScript.Echo "Exporting info for folder:  " & CurrFolder & fl
			'Get the physical path
			StrPhysical = objSite.GetPhysicalPath(CurrFolder & fl)			
			IF objFSO2.FolderExists(strPhysical) THEN
				folderStat = "The folder exists"
			ELSE
				folderStat = "Sorry this folder does not exist"
				'If Delete Flag is set remove VFS Entries where Physical folder does not exist
				if delFlag = "True" then
					objSite.RemoveFolder(CurrFolder & fl)
					folderStat = folderStat & " and has been removed from VFS"
					recurseFlag = 0
				end if
			END IF
			'output infomaion to logfile
			objLogFile.WriteLine(CurrFolder & fl & ", " & StrPhysical & ", " & folderStat)
			'if the recurseFlag is set, call GetNextFolder again.
			if recurseFlag > 0 then
				GetNextFolder CurrFolder & fl,objSite
			End if
		Next
		'if Err.Number <> 0 Then
		'		objLogFile.WriteLine(CurrFolder & fl & ", " & ", ERROR-FOLDER NOT FOUND IN VFS")
		'		DisplayErrorInfo (CurrFolder & fl)
		'		folderStat = "ERROR-FOLDER NOT FOUND IN VFS"
		'	else
		'		IF objFSO2.FolderExists(strPhysical) THEN
		'			folderStat = "The folder exists"
		'		ELSE
		'			folderStat = "Sorry this folder does not exist"
		'			'If Delete Flag is set remove VFS Entries where Physical folder does not exist
		'			if delFlag = "True" then
		'				objSite.RemoveFolder(CurrFolder & fl)
		'			end if
		'		END IF
		'		'output infomaion to logfile
		'	End IF 'error2
	end if 'No Error
End Function

Function StripVirtualPortion(ByVal sPath)
	
	Dim iPos , sVirtualFolderPath,bIsVirtual
	
	iPos = InStr(1, sPath, " - Virtual", 1 )
	If ( iPos > 0 ) Then
		'WScript.Echo "-->Stripping VIRTUAL portion of folder name"
		sVirtualFolderPath = sPath
		sPath = Left( sPath, iPos -1 )
	End If
	
	StripVirtualPortion = sPath
End Function


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

Sub DisplayErrorInfo (CurrFolder)
	objErrorLogFile.WriteLine(CurrFolder & ", " & Err & ", " & Hex(Err) & ", " & Err.Source & ", " & Err.Description)
	WScript.Echo "Folder      : " & CurrFolder
    WScript.Echo "Error:      : " & Err
    WScript.Echo "Error (hex) : &H" & Hex(Err)
    WScript.Echo "Source      : " & Err.Source
    WScript.Echo "Description : " & Err.Description
    Err.Clear

End Sub