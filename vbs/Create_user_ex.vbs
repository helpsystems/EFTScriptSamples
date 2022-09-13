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

   ' This is the username that will be created
   txtLogin = "TestUser15"
   
      ' This specifies the password of the user.
   txtPassword = "Password_321!" 
   
   ' This specifies the full name of the user (account details).
   txtFullName = "Test User"
   
   ' This specifies the email of the user (account details).
   txtEmail = "abaciu@iiroc.ca"
   
    ' This specifies whether or not a folder will be created for the user. If "true", a user home folder will be created with the Login name, example: /Usr/UserA.
	'If false, it will not create a folder for the user and it will instead inherit the folder from the template
   txtCreateHomeFolder = "false"

   'This specifies whether or not the user will have full permissions to the home folder.
   txtFullPermissionsForHomeFolder = "true"

   
Dim theSite

Call ConnectToServerEx()
Call FindSite()
Call RunCreateUserEX2()

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
Sub RunCreateUserEX2()

	Set NewUserData = WScript.CreateObject("SFTPCOMInterface.CINewUserData")

	NewUserData.Login = txtLogin
	NewUserData.FullName = txtfullName
	NewUserData.Email = txtemail
	NewUserData.Password = txtpassword
	NewUserData.CreateHomeFolder = txtCreateHomeFolder
	NewUserData.FullPermissionsForHomeFolder= txtFullPermissionsForHomeFolder

	WScript.Echo ""
	WScript.Echo "Creating user with Login: " & NewUserData.Login
	WScript.Echo "Creating user with Password: " & NewUserData.Password
	WScript.Echo "Creating user with Full Name (account detail): " & NewUserData.FullName
	WScript.Echo "Creating user with Email (account detail): " & NewUserData.Email
	
	' The below lines will output whether or not a home folder will be created for the user
	if (NewUserData.CreateHomeFolder = false) Then
		WScript.Echo "The user will inherit the Default Settings Template Home folder"
		else
		WScript.Echo "A folder /" & NewUserData.Login & " will be created in the Settings Template Root Folder"
	end if 

	' The below line will output whether or not the user will receive full permission to their home folder.
	if (NewUserData.FullPermissionsForHomeFolder = false) Then
		WScript.Echo "The user will not receive full permission to their home folder"
		else
		WScript.Echo "The user will receive full permission to their home folder"
	end if 	
	
	theSite.CreateUserEX2(NewUserData)
	
End Sub

