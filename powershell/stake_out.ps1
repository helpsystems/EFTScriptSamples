<#
.SYNOPSIS
   Data collection using tools such Procmon, Procdump and Wireshark

.DESCRIPTION
   This script enables an admnistrator to collect data on their server at times when they are unable to observe the issue live.

.DISCLAIMER
    This script is provided without warranty. Globalscape/Helpsystems does not assume any liability for unintended functionality as a result of this script.
.VERSION
    1.0
    1.1 Added wireshark portable and set procmon to close itself. Also removed /nofilter in procmon.
.AUTHOR
    Jonathan Branan jbranan@globalscape.com jonathan.branan@helpsystems.com
#>

#------------------------------------------------------------
# Main Variables
#------------------------------------------------------------
$working_drive = 'c:'
$working_directory = 'C:\Users\jbranan\Desktop\scripts\stake_out'
$total_time = 20

#------------------------------------------------------------
# Procmon related variables
#------------------------------------------------------------
$procmon_filename = 'log.pml'

#------------------------------------------------------------
# Wireshark related variables
#------------------------------------------------------------
$wireshark_filename = 'capture.pcapng'
$wireshark_drive = 'c:'
$wireshark_location = 'C:\Users\jbranan\Desktop\scripts\stake_out\WiresharkPortable'
$wireshark_filter = 'host 192.168.102.10'
$total_wireshark_time = $total_time + 15

#------------------------------------------------------------
# Procdump related variables
#------------------------------------------------------------
$take_service_dumps = $false
$take_gui_dumps = $false
$number_of_dumps = 3
$total_procdump_time = 60
$total_procdump_time_close = $total_procdump_time + 15

#------------------------------------------------------------
# Procmon blocks
#------------------------------------------------------------ 
Start-Job -Name procmon -ScriptBlock {
$using:working_drive
cd $using:working_directory"\procmon"
./procmon.exe /accepteula /Quiet /BackingFile $using:working_directory"\dumps\"$using:procmon_filename /Minimized /Runtime $using:total_time
}

#Start-Job -Name kill-procmon -ScriptBlock {
#sleep -Seconds $using:total_time
#
#taskkill /IM "Procmon64.exe" /F
#Stop-Job -Name procmon
#exit
#}

#------------------------------------------------------------
# Wireshark blocks
#------------------------------------------------------------
Start-Job -Name wireshark -ScriptBlock {
$using:wireshark_drive
cd $using:wireshark_location
./WiresharkPortable -k -i Ethernet0 -f "$using:wireshark_filter" -a duration:$using:total_time -w $using:working_directory"\dumps\"$using:wireshark_filename
}

Start-Job -Name kill-wireshark -ScriptBlock {
sleep -Seconds $using:total_wireshark_time
taskkill /IM "Wireshark.exe" /F
Stop-Job -Name wireshark
exit
}

#------------------------------------------------------------
# Procdump blocks
#------------------------------------------------------------
#
if ($take_service_dumps) {
    Start-Job -Name procdump_EFT_service -ScriptBlock {
    $using:working_drive
    cd $using:working_directory"\procdump"
    ./procdump.exe -n $using:number_of_dumps -s $using:total_procdump_time -ma cftpstes.exe $using:working_directory"\dumps" -accepteula
    timeout /T $using:total_procdump_time_close
    exit
    }
}

if ($take_gui_dumps) {
    Start-Job -Name procdump_gui_service -ScriptBlock {
    $using:working_drive
    cd $using:working_directory"\procdump"
    ./procdump.exe -n $using:number_of_dumps -s $using:total_procdump_time -ma cftpsai.exe $using:working_directory"\dumps" -accepteula
    timeout /T $using:total_procdump_time_close
    exit
    }
}