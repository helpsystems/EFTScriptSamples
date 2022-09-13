dim template
dim oServer, oSites, oSite, oTemplate
set oServer = CreateObject ("SFTPCOMInterface.CIServer")
template = "new"

oServer.connect  "localhost", 1111,"eftadmin","a"
set oSites = oServer.Sites()

for i = 0 to oSites.Count() -1
	set oSite = oSites.Item (i)
	if oSite.Name = "GS" Then
		exit for
	 end if
next 

set oTemplate = oSite.GetSettingsLevelSettings (template)
dim forced, isInherited
forced = oTemplate.GetForcePasswordResetOnInitialLogin(isInherited)
Wscript.Echo  "template: " & template & "; ForcePasswordResetOnInitialLogin: " & forced & "; inherited: " & isInherited

oServer.close