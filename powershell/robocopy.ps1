$destinationFolder = "\\TERRA0372016\Users\jbranan\Desktop\share\New folder "
$restoredLocation = "\\TERRA0372016\Users\jbranan\Desktop\share\abetest "

$exportfilelocation2 = "d:\restored.txt"

Robocopy /E /XC /XN /XO $restoredLocation $destinationFolder > $exportfilelocation2