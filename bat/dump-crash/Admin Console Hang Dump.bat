pushd "%~d0\"
pushd "%~dp0\"
"%~dp0procdump.exe" -n 3 -s 60 -ma -accepteula cftpsai.exe .\
pause