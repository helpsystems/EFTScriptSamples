How to capture Crash/Hang dumps:

Hang Dumps:
Use "Admin Console Hang Dump.bat" and "EFT Service Hang Dump.bat".

Crash Dump:
Merge the WER.reg registry key and make a folder at C:\dumps if you wish to capture crash dumps. You can edit the path of the dumps folder in the WER.reg file or edit directly in the registry after merging it. Make sure it is done for both services.