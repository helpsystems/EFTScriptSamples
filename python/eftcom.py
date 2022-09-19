import win32com.client as win32
from pathlib import Path
 
server = win32.gencache.EnsureDispatch('SFTPCOMInterface.CIServer')
server.ConnectEx('localhost', 1100, 0, 'scripting', 'password')