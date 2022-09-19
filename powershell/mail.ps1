$smtpserver = "mail.globalscape.com"
$from = "watchdog@server.com"
$to = "jonathan.branan@helpsystems.com"
$subject = "Folder Watch Dog"
$port = 25


$body = "Hi there,<br />Folders reaching the limit:<br /><br />"

#Send the email
Send-MailMessage -smtpserver $smtpserver -Port $port -from $from -to $to -subject $subject -body $body -bodyashtml