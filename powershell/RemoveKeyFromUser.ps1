$server_ip = "192.168.102.28"
$server_port = 1100
$admin_username = "insight"
$admin_password = "a"
$site_name = "GS"

$server = New-Object -ComObject SFTPCOMInterface.CIServer
$server.connect($server_ip,$server_port,$admin_username,$admin_password)

$site_list = $server.Sites()

for ($i = 0; $i -lt $site_list.Count(); $i++) {
    $site = $site_list.Item($i)
    if ($site.Name -eq $site_name) {
        break
    }
}

$date = "11/1/2006"
$date = [datetime] $date

$username = Read-Host "Which user do you want to remove a key from?"

$settings = $site.GetUserSettings($username)

$settings.setExpirationDate($date, 0)