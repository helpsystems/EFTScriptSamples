@echo off
c:\
cd "C:\Users\jbranan\Desktop\Batch to call multiple things\procdump"
procdump.exe -n 1 -ma cftpstes.exe "C:\Users\jbranan\Desktop\Batch to call multiple things\dumps" -accepteula
timeout /T 15
exit