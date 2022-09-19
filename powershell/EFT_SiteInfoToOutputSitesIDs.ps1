$serverIp = "localhost"
$serverPort = 1100
$serverUsername = "a"
$serverPassword = "a"

$EFTServer = New-Object -COM "SFTPCOMInterface.CIServer"
$EFTServer.ConnectEX($serverIP, $serverPort, 0, $serverUsername, $serverPassword)
$EFTServer.Sites().Count()

for($j = 0; $j -lt $EFTServer.Sites().Count(); $j++)
{
Write-Host "Site Index - Site Name - Site GUID"
$a = $j + 1
Write-Host $a - $EFTServer.Sites().Item($j).Name - $EFTServer.Sites().Item($j).GUID
}