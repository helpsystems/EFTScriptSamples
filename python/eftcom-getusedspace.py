import win32com.client as win32
from pathlib import Path
 
server = win32.gencache.EnsureDispatch('SFTPCOMInterface.CIServer')
server.ConnectEx('192.168.4.14', 1100, 0, 'a', 'QjIlmT4H')

a = server.ICIClientSettings.GetUsedSpace

print(a)