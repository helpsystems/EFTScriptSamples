@echo off
c:\
cd "C:\Users\jbranan\Desktop\Batch to call multiple things"
start wireshark.bat
start procdump.bat
start procmon.bat
timeout /T 135
start killwireshark.bat
start killprocmon.bat
exit