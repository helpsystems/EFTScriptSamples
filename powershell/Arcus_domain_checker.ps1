$clients_to_check = @('a', 'b')

foreach($client in $clients_to_check){
Start-Process https://$client.arcusapp.globalscape.com
}