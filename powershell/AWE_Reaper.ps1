$startTimeLimit = (get-date) - (new-timespan -minutes 2)
$processes_to_kill = get-process | 
    where {$_.StartTime -lt $startTimeLimit -and ($_.path -like "GSAWE.exe") }
if ($processes_to_kill -ne $null)
{
    $processes_to_kill | foreach { $_.Kill() }
}