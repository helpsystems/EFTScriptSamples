'
' FILE: CreateUserEX2.vbs
' AUTHOR: Brian Arriaga
' CREATED: 17 MAR 2015
' MODIFIED:  17 MAR 2015
' ORIGINALLY CREATED FOR: EFT Server 6.5-7.0.3
' PURPOSE: This script creates a specified user using the CreateUserEX2 method.
' 
' NOTE: The creation and modification of COM API scripts is not within the standard scope of Support.
' All COM API scripts are supplied as a courtesy "AS IS" with no implied or explicit guarantee of function.
' GlobalSCAPE is not responsible for any damage to system or data as a result of using supplied COM API scripts.
' Further information and usage instruction on COM API methods can be found online within the help file: http://help.globalscape.com/help/
'

Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

'Modify the below connection details to reflect your own environment.
   txtServer = "192.168.102.28"
   txtPort =  "1100"
   txtAdminUserName = "eftadmin"
   txtAdminPassword = "a"
   txtSiteName = "GS"
   createdFolder = "/Usr/created"
   
Dim theSite

Call ConnectToServerEx()
Call FindSite()
Call CreatePhysical()

SFTPServer.Close
Set SFTPServer = nothing

'==========================================
'This sub connects to the server with AD authentication
'=========================================
Sub ConnectToServerEx()
	SFTPServer.ConnectEx txtServer, txtPort, 1, "", ""

	WScript.Echo "Connected to EFT Server: "  & txtServer
End Sub

'==========================================
'This sub connects to the server
'=========================================
Sub ConnectToServer()
	SFTPServer.Connect txtServer, txtPort, txtAdminUserName, txtAdminPassword

	WScript.Echo "Connected to EFT Server: "  & txtServer
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
	WScript.Echo "Connected to site: " & theSite.Name
End Sub

'==========================================
'This sub Initializes the CINewUserData property, sets the variables and then creates a user account using the CreateUserEX2() method.
'=========================================	
Sub CreatePhysical()
	theSite.CreatePHysicalFolder(createdFolder)
	
End Sub

