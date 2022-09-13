<#
.SYNOPSIS
   Use EFT's COM interface to configure ARM settings for auditing and reporting.

.DESCRIPTION
   Use EFT's COM interface to retrieve ARM settings

.PARAMETER serverName
   
.PARAMETER eftAdminPort

.PARAMETER authMethod

.PARAMETER eftAdminName

.PARAMETER eftAdminPassword

#>

param(
	[Parameter(Mandatory=$False)][string]$serverName = "localhost",
	[Parameter(Mandatory=$False)][int]$eftAdminPort = 1100,
	[Parameter(Mandatory=$False)][int]$authMethod = 1,
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
}
catch {
    $errorMessage = $_.Exception.Message;
    Write-Host "failed to connect to server ${serverName}: ${errorMessage}"
    Exit;
}


#------------------------------------------------------------
# get ARM settings
#------------------------------------------------------------

Write-Output ("ARMServerName: {0}" -f $oServer.ARMServerName)
Write-Output ("ARMDatabaseName: {0}" -f $oServer.ARMDatabaseName)
Write-Output ("ARMUserName: {0}" -f $oServer.ARMUserName)
Write-Output ("ARMPassword: {0}" -f $oServer.ARMPassword)
Write-Output ("ARMDatabaseType: {0}" -f $oServer.ARMDatabaseType)
Write-Output ("ARMAuthenticationType: {0}" -f $oServer.ARMAuthenticationType)

#------------------------------------------------------------
# close resources
#------------------------------------------------------------

$oServer.Close()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($oServer) | out-null
Remove-Variable oServer

