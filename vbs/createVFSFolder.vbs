Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))
txtServer = "localhost"
txtPort =  "1100"
txtAdminUserName = "eftadmin"
txtPassword = "a"
siteName = "GS"

'Input boxes **do not modify**
msgTitle = "Globalscape EFT Server"
isPhysMessage = "Is the folder physical or virtual? (Type p for physical and v for virtual"
physFolderMessage = "Enter the full path of the physical folder...."
aliasMessage = "Enter the full path of the alias..."
physRefMessage = "Enter the physical path reference for the virtual folder..."

If Not Connect(txtServer, txtPort, txtAdminUserName, txtPassword) Then
  WScript.Quit(0)
End If

set selectedSite = Nothing
set sites = SFTPServer.Sites()
For i = 0 To sites.Count -1
  set site = sites.Item(i)
  If site.Name = siteName Then
    set selectedSite = site
    Exit For
  End If
Next

'physical or virtual?
txtIsPhys = InputBox (isPhysMessage, msgTitle)

if txtIsPhys = "p" then
txtPhysPath = InputBox (physFolderMessage, msgTitle)
selectedSite.CreatePhysicalFolder(txtPhysPath)
end if

if txtIsPhys = "v" then
txtAliasPath = InputBox (aliasMessage, msgTitle)
txtPhysRef = InputBox (physRefMessage, msgTitle)
Call selectedSite.CreateVirtualFolder(txtAliasPath, txtPhysRef)
end if

WScript.Echo "Done"

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