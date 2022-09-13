<#
Sql Import Script

Keith Lowery, Erich Leenheer, Jonathan Branan

This script is provided without warranty. Globalscape does not accept 
responsibility for any unexpected outcomes that result from use of this script.

Version 1.0 Added variables and checking for open sql connections
Version 1.1 Added comments
#>

# SQL Instance
$DBServer = "192.168.102.18\Globalscape"

#Database Name
$DBName = "eft1"

#Folder where the .sql files are stored
$databasefolder = "C:\Temp\sql"


#Connect to SQL Server
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString= "Server=$DBServer;Database=$DBName;Integrated Security=True;"
$sqlConnection.Open()
if ($sqlConnection.State -ne [Data.ConnectionState]::Open) {
    "Connection to DB is not open."
    Exit
}
Get-ChildItem $databaseFolder -Filter *.sql -Recurse | ForEach-Object { sqlcmd -S  $DBServer -d $DBName -E -i $_.FullName } 
if ($sqlConnection.State -eq [Data.ConnectionState]::Open) {
    $sqlConnection.Close()
}