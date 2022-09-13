Set SFTPServer = WScript.CreateObject("SFTPCOMInterface.CIServer")

CRLF = (Chr(13)& Chr(10))
txtServer = "localhost"
txtPort =  "1100"
txtAdminUserName = "eftadmin"
txtPassword = "a"

If Not Connect(txtServer, txtPort, txtAdminUserName, txtPassword) Then
  WScript.Quit(0)
End If

siteName = "GS"
set siteToRemove = Nothing
set sites = SFTPServer.Sites()
For i = 0 To sites.Count -1
  set site = sites.Item(i)
  If site.Name = siteName Then
    set siteToRemove = site
    Exit For
  End If
Next

'EventType:
'OnTimer = 4097,
'OnLogRotate = 4098,
'OnServiceStopped = 4099,
'OnServiceStarted = 4100,
'MonitorFolder = 4101,
'OnMonitorFolderFailed = 4102,
'OnSiteStarted = 8193,
'OnSiteStopped = 8194,
'OnIPAddedToBanList = 8195,
'OnClientConnected = 12289,
'OnClientConnectionFailed = 12290,
'OnClientDisconnected = 12291,
'OnClientDisabled = 16385,
'OnClientQuotaExceeded = 16386,
'OnClientLoggedOut = 16387,
'OnClientLoggedIn = 16388,
'OnClientLoginFailed = 16389,
'OnClientPasswordChanged = 16390,
'OnClientCreated = 16391,
'OnClientLocked = 16392,
'OnFileDeleted = 20481,
'OnFileUpload = 20482,
'BeforeFileDownload = 20483,
'OnFileDownload = 20484,
'OnFileRenamed = 20485,
'OnFolderCreated = 20486,
'OnFolderDeleted = 20487,
'OnUploadFailed = 20489,
'OnDownloadFailed = 20490,
'OnChangeFolder = 20491,
'OnFileMoved = 20492,
'OnVerifiedUploadSuccess = 20493,
'OnVerifiedUploadFailure = 20494,
'OnVerifiedDownloadSuccess = 20495,
'OnVerifiedDownloadFailure = 20496,
'AS2InboundTransactionSucceeded = 24577,
'AS2InboundTransactionFailed = 24578,
'AS2OutboundTransactionSucceeded = 24579,
'AS2OutboundTransactionFailed = 24580,

If Not siteToRemove Is Nothing Then
  
  Set rules = site.EventRules(4101)

  Set objParams = WScript.CreateObject("SFTPCOMInterface.CIFolderMonitorEventRuleParams")

  objParams.Name = "TestFolderMon13"
  objParams.Enabled = true
  objParams.Description = "This is a test event rule"
  objParams.Path = "C:\wd\monitor"

'Recurrence:
'    Recurrence_Continually = 0,
'    Recurrence_Daily = 1,
'    Recurrence_Weekly = 2,
'    Recurrence_Monthly = 3,
'    Recurrence_Yearly = 4,
'    Recurrence_Once = 5,
'    Recurrence_Calendar = 6,


  Set eventRule = rules.Add(rules.Count(), objParams)
  
  'Add "If File name matches "*.txt" or "*.exe"" condition:
  dim cond
	set cond = eventRule.AddIfStatement(0, 5005, 16, Array("*.txt", "*.exe"), -1)

  Set mail = WScript.CreateObject("SFTPCOMInterface.CIMailActionParams")
  mail.Body = "Test email"
  mail.Subject = "Test"
  mail.TOAddresses = "youremail@youdomain.com"
	cond.ifSection.Add 0, mail
 
End If

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