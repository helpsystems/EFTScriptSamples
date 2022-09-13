#James McGregor uwu and Jonathan Branan

$ConnectionString = "server=localhost\SQLEXPRESS,1433;database=EFTDB;UID=eft;Pwd=password1;"
$queryFile = "C:\Users\jbranan\Desktop\PurgeEFT.sql"

Function LogWrite
{
   Param ([string]$logstring)
   $curDate = getdate
   $toWrite = $curDate + $logstring
   Write-Host $toWrite
   Add-content $Logfile -value $toWrite
}

Function getdate
{
    Get-Date -Format "MM/dd/yyyy "
}
#$currenttime = getdate

$Logfile = "c:\Users\jbranan\Desktop\purge.log"

Write-Host "Running query for Jonny Boi"
$logstring = Invoke-Sqlcmd -ConnectionString $ConnectionString -InputFile $queryFile -Verbose 4>&1
Logwrite $logstring