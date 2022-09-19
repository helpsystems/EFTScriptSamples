$AMLHead = '</AMTASKHEAD>

<AMFUNCTION NAME="Main" ACCESS="private" RETURNTYPE="variable">'

# Set Variable to replace start of AWE with Start of AWE and Capture PID flow
    #Change "<AMFILESYSTEM ACTIVITY" Line to a file location on your server

$AMLtask = '</AMTASKHEAD>

<AMFUNCTION NAME="Main" ACCESS="private" RETURNTYPE="variable">
<AMVARIABLE NAME="ProcessPID" VALUE="" PRIVATE="YES" />
<AMSCRIPT>Declare Function GetCurrentProcessId Lib "kernel32" () As Long
    Sub Main
    ProcessPID = GetCurrentProcessId()
End Sub</AMSCRIPT>
<AMFILESYSTEM ACTIVITY="write_file" FILE="C:\Temp\PID%ProcessPID%.log">%Now()%, %GetTaskName()% --- %AWE_TASK_NAME%, PID: %ProcessPID%</AMFILESYSTEM>

'
Get-ChildItem 'C:\Users\jbranan\Desktop\test\*.aml' -Recurse | ForEach {
     (Get-Content $_ | ForEach  { $_ -replace $AMLHead, $AMLtask }) |
     Set-Content $_
}