#List of hostnames
$hostnames=@("CELES0272016","TERRA0372016");

#EFT Admin Credentials
$EFTAdminUsername = "a";
$EFTAdminPassword = "a";
$EFTAdminPort = 1100;

#EFT Com Object
$script:EftServer = $null

#List of hostnames that can be administrated at the same time
$output=@();
#$output=$hostnames# Debug, uncomment this line and set $lockfailure to "true".
#String representing lock failure.
$lockfailure=$false;

#Output <DATE> <TIME> <UTC Offset>
Function getdate
{
    Get-Date -Format "MM/dd/yyyy HH:mm:ss K "
}
$currenttime = getdate

#Path to log file
$Logfile = "\\IV-S2019B-3\config\adminlock.log"

#Function to accept string input and append to $Logfile
Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}
#$EFTnodename = ''
#Set-Variable -Name "EFTnodename" ($EFT_CONTEXT.GetVariable("SERVER.NODE_NAME"))
#$logstring = $EFTnodename
#LogWrite $logstring
#Main, Loop through hostnames in $hostname array and attempt connection via com.Successful connections are counted by $flag. 
#If a COM connection is successful to more than one server in the array, the $lockfailure variable is set to true. 
$flag=0;
$output=''
for ($i=0;$i -le $hostnames.count-1; $i++){
	foreach ($EFTAdminHostname in $hostnames[$i]){
		$script:EftServer = new-object -ComObject "SFTPCOMInterface.CIServer"
		try {
			$script:EftServer.ConnectEx($EFTAdminHostname, $EFTAdminPort, $EFTAdminAuthType, $EFTAdminUsername, $EFTAdminPassword)
			$flag++;
            $output=$output +' '+ $EFTAdminHostname
            $script:EftServer.close();
		}
		catch [System.Runtime.InteropServices.COMException] {
		}
	}
	if ($flag -gt 1){
		$lockfailure=$true;
	}
}
if ($lockfailure -eq $true){
	$lockstatus = 'AdminsLock unstable.';
	$lockstatusdetail = " Multiple servers can be accessed:"+' '+$output;
    $logstring= $currenttime + $lockstatus + $lockstatusdetail+" LockFailure:Yes" +" Flag:"+ $flag #+ " ERNode:" + $EFT_CONTEXT.GetVariable("SERVER.NODE_NAME")
    Write-Host $currenttime $lockstatus $lockstatusdetail
    LogWrite $logstring
}
else{
    $lockstatus = 'AdminsLock stable.'
    $lockstatusdetail = " Connected to:"+' '+$output;
    $logstring= $currenttime + $lockstatus +$lockstatusdetail + " LockFailure:No" +" Flag:"+ $flag #+ " ERNode:" + $EFT_CONTEXT.GetVariable("SERVER.NODE_NAME")
    Write-Host $currenttime $lockstatus + $output
    LogWrite $logstring
}