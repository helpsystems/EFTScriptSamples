'FILENAME:	 	Import Virtual Folders.vbs
'DATE:	 		19 April 2011
'PROGRAMMER:	A. ACUNA
'USE:			Use this to export all the virtual folders in a site.
'**** run cmd "cscript (script location) > (location of output txt document)****


Dim g_arrFileLines()

Dim strHost, strLogin, strPassword, strTextFile, strSite, strPort
Dim oSFTPServer, oSites, oSite

'Create GlobalSCAPE object
Set oSFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

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

Call ConnectAndLogin()
Call ReadVFSData()
Call ImportVFSData()

oSFTPServer.Close
Set oSFTPServer = nothing

Sub ImportVFSData()
	Dim i,j,iPos,arLine
	'WScript.Echo "DEBUG:  ImportVFSData i = " & i
	'WScript.Echo "DEBUG:  notes on i = " & UBound(g_arrFileLines)
	For i = Lbound(g_arrFileLines) to UBound(g_arrFileLines)
		'WScript.Echo "DEBUG:  ImportVFSData i = " & i
		'WScript.Echo "DEBUG:  g_arrFileLines i = " & g_arrFileLines(i)
		arLine = Split(g_arrFileLines(i),",")
		strVirtualP = arLine(0)
		strPhysicalP = arLine(1)
		WScript.Echo "Creating Virtual Folder: " & strVirtualP
		WScript.Echo "Using Path:  " & strPhysicalP
		On Error Resume Next
		Err.Clear
		Call oSite.CreateVirtualFolder(strVirtualP, strPhysicalP)
		If Err.Number<>0 then
			If InStr(1,Err.Description,"MX Error: 27",1) > 0 Then
				oSite.RemoveFolder(strVirtualP)
				Call oSite.CreateVirtualFolder(strVirtualP, strPhysicalP)
			Else
				WScript.Echo "-*-ERROR: " & Err.Description
				WScript.Echo "-*-ERROR: Failed to create Virtual folder:  " & strVirtualP
				WScript.Echo "Check virtual and physical folder." & Err.Description
			End if
		End if
	Next
	'.Echo "DEBUG:  ImportVFSData Final i = " & i
End Sub



'==============================================================================
'
'   ReadVFSData
'
'   Read the data from the text file and create an
'
'==============================================================================
Sub  ReadVFSData()
	Dim i: i = 0
	'WScript.Echo "DEBUG:  readVFSData i =" & i
	Dim oFSO, oFile
	Set oFSO = CreateObject("Scripting.FileSystemObject")
	Set oFile = oFSO.OpenTextFile( strTextFile, 1 ) 
	Do Until oFile.AtEndOfStream 
		Redim Preserve g_arrFileLines(i) 
		'WScript.Echo "DEBUG:  readVFSData i =" & i
		g_arrFileLines(i) = oFile.ReadLine
		'WScript.Echo "DEBUG:  g_arrFileLines i =" & g_arrFileLines(i)
		i = i + 1 
	Loop 
	'WScript.Echo "DEBUG:  readVFSData i =" & i
	oFile.Close
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

'==============================================================================
'   Syntax
'   Show the command-line syntax
'==============================================================================
public function Syntax
	wscript.echo  "Purpose:   Import Virtual Folders from a text file." & vbCrLf & _
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

End Sub 'End ConnectAndLogin