<#
.SYNOPSIS
   Watchdog Script that will send a notification if a folder gets too full.

.DESCRIPTION
   The Script will Send E-Mail for folders with files over a specified amount. This ammount is controlled by the $filelimit variable. 
   The script supports searching multiple directories; The folders will need to be inserted into the array $folderlist.
   Change the SMTP server variable block to work in your environment.

.AUTHOR
    Jonathan Branan <jbranan@globalscape.com>
.WARRANTY
    This script is provided with no warranty and is not garunteed to work. Globalscape, Helpsystems or the Author assume NO responsibility for
    the outcome of running the script.
#>

# List of folders to parse. Delimit by commas, make sure the paths are in double quotes.
$folderlist = @("C:\InetPub\EFTRoot\MySite")
# Minimum of files in a directory before the notfication is sent.
$filelimit = 100

#SMTP Server Block # CHANGE ME
$smtpserver = "mail.globalscape.com"
$from = "watchdog@server.com"
$to = "jbranan@globalscape.com"
$subject = "Folder Watch Dog"
$port = 25

$data = ForEach($Folder in $folderlist){
Get-ChildItem $Folder -Directory -Recurse|
	ForEach-Object{
		[pscustomobject]@{
			FullName  = $_.Fullname.ToLower()
			FileCount = $_.GetFiles().Count
            # Filters
		} | Where-Object {$_.FileCount -ge $filelimit} | Where-Object {$_.FullName -cnotlike '*archive*'}
	}
} 

# Building a table
$tbl = New-Object System.Data.DataTable "FileCount"
$col1 = New-Object System.Data.DataColumn FullName
$col2 = New-Object System.Data.DataColumn FileCount
$tbl.Columns.Add($col1)
$tbl.Columns.Add($col2)

ForEach($array in $data){
            $row = $tbl.NewRow()
            $row.FullName = $array.FullName
            $row.FileCount = $array.FileCount
            $tbl.Rows.Add($row)
}

# Formatting the table so we can email it
$html = $tbl | Select-Object Fullname, Filecount | ConvertTo-Html -Property FullName, FileCount -Title 'Folders reaching the file limit'
$body = "Hi there,<br />Folders reaching the limit:<br /><br />" + $html

#Send the email
Send-MailMessage -smtpserver $smtpserver -Port $port -from $from -to $to -subject $subject -body $body -bodyashtml

#You can comment out Send-MailMessage and uncomment out the next line if you wish to debug filters
#$tbl | Select-Object Fullname, Filecount