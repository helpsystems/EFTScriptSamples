$destinationFolder = "\\file.core.windows.net\gsbdata\InetPub\EFTRoot\gsbsup\Usr\Projects\SEG\ "
$restoredLocation = "\\file.core.windows.net\gsbdata\InetPub\EFTRoot\RestoredFiles\PubTech_20210128\ "

$exportfilelocation2 = "d:\restored.txt"

Robocopy /E /XC /XN /XO $restoredLocation $destinationFolder > $exportfilelocation2