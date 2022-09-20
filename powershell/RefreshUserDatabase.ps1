<#
.SYNOPSIS
   Use EFT's COM interface to refresh the User Database for a specific site.

.DESCRIPTION
   Use EFT's COM interface to programatically refresh the User Database for a site

.PARAMETER serverName
   
.PARAMETER eftAdminPort

.PARAMETER authMethod

.PARAMETER eftAdminName

.PARAMETER eftAdminPassword

#>

#------------------------------------------------------------
# Site Index First = 0, Second = 1 etc.
#------------------------------------------------------------

param(
	[Parameter(Mandatory=$False)][string]$serverName = "localhost",
	[Parameter(Mandatory=$False)][int]$eftAdminPort = 1100,
	[Parameter(Mandatory=$False)][int]$authMethod = 1,
	[Parameter(Mandatory=$False)][int]$siteIndex = 1,
	[Parameter(Mandatory=$False)][string]$eftAdminName = "",
	[Parameter(Mandatory=$False)][string]$eftAdminPassword = ""
)

#------------------------------------------------------------
# login as admin
#------------------------------------------------------------

try {
    $oServer = New-Object -ComObject 'SFTPComInterface.CIServer'
    $oServer.ConnectEx( $serverName, $eftAdminPort, $authMethod, $eftAdminName, $eftAdminPassword );
    Write-Host "connected"
    $oSite = $oServer.Sites().Item($siteIndex)
}
catch {
    $errorMessage = $_.Exception.Message;
    Write-Host "failed to connect to server ${serverName}: ${errorMessage}"
    Exit;
}

#------------------------------------------------------------
# Sync the database
#------------------------------------------------------------

$oSite.ForceSynchronizeUserDatabase()

#------------------------------------------------------------
# close resources
#------------------------------------------------------------

$oServer.Close()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($oServer) | out-null
Remove-Variable oServer