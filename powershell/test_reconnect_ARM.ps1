<#
.SYNOPSIS
   Use EFT's COM interface to configure ARM settings for auditing and reporting.

.DESCRIPTION
   Use EFT's COM interface to check status of ARM and reconnect if needed

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
# Setup logging to a file
#------------------------------------------------------------
#Output <DATE> <TIME> <UTC Offset>
Function getdate
{
    Get-Date -Format "MM/dd/yyyy HH:mm:ss K "
}
$currenttime = getdate

#Path to log file
$Logfile = "C:\Users\jbranan\Desktop\ARM-Connection.log"

#Function to accept string input and append to $Logfile
Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

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

#Write-Output ("ARMServerName: {0}" -f $oServer.ARMServerName)
if ($oServer.ARMTestConnection())
    {
    Write-Output ('ARM Test Connection Succeeded.')
    $logstring= $currenttime + 'ARM Test Connection Succeeded.'
    LogWrite $logstring
    if ($oServer.ARMReconnect())
        {
    Write-Output 'ARM Is Connected.'
    $logstring= $currenttime + 'ARM Is Connected.'
    LogWrite $logstring
         }
    else 
        {
    write-output 'Failed To Reconnect ARM.'
    $logstring= $currenttime + 'Failed To Reconnect ARM.'
    LogWrite $logstring
         }
    }
else
    {
    Write-Output ('ARM Test Connection Failed.')
    $logstring=$currenttime + 'ARM Test Connection Failed.'
    LogWrite $logstring
    }
#$oServer.ARMReconnect()
#------------------------------------------------------------
# close resources
#------------------------------------------------------------

$oServer.Close()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($oServer) | out-null
Remove-Variable oServer