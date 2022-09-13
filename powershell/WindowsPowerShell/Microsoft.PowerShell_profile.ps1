function rdgw {
Write-Host "Logging on to the Arcus Management Server..."
sft rdp --via rdgwbastion ArcusSupport
}

function list {
Write-Host "Listing servers..."
sft list-servers
}

function help {
write-host "rdgw - Use to connect to the Arcus domain management server."
write-host "list - List of all servers you have access to in the environment."
write-host "search - String search. I suggest using this with the clients 6 digit identifier to filter all servers in their environment."
write-host "legacy - Use to log into non arcus servers. There are not very many left..."
write-host "arcus - Use to log into arcus servers. There are too many..."
write-host "wfh - Use to log into arcus servers from home."
}

function search {
param(
	[Parameter(Mandatory=$False)][string]$server
)
if ($server)
       {
        Write-Host "Listing servers..."
        sft list-servers | findstr -i $server 
       }
else{
    $server = Read-Host -Prompt "I need the client's 6 digit identifier. Example'Supp02'"
    Write-Host "Listing servers..."
	sft list-servers | findstr -i $server }
$Results = Read-Host -Prompt 'How do you want to connect? Use help if you are unsure.
arcus,legacy or wfh?'
invoke-expression $Results
}

function legacy {
Write-Host 'Connecting to legacy...'
$legacy = Read-Host -Prompt 'Server name?'
Write-Host "sft rdp $legacy"
sft rdp $legacy
}

function arcus {
Write-Host 'Connecting to Arcus...'
$bastion = Read-Host -Prompt 'Bastion name?'
$vm = Read-Host -Prompt 'Server name?'
Write-Host "sft rdp --via $bastion $vm"
sft rdp --via $bastion $vm
}

function wfh {
Write-Host 'Connecting from home...'
$bastion = Read-Host -Prompt 'Bastion name?'
$vm = Read-Host -Prompt 'Server name?'
Write-Host "sft rdp --via sft --via $bastion $vm"
sft rdp --via sft --via $bastion $vm
}