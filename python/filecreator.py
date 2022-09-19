import os
import string
from datetime import datetime

now = datetime.now() # current date and time
tm = now.strftime("X%mX%dX%y-X%HX%MX%S").replace('X0','X').replace('X','')

file = 'test'
ext = '.txt'
# Must be forward slashes
outputdirectory = 'C:/tmp/work/'
fsize = '1gb'

go = True
class Del:
  def __init__(self, keep=string.digits + '.'):
    self.comp = dict((ord(c),c) for c in keep)
  def __getitem__(self, k):
    return self.comp.get(k)
DD = Del()
fname = f'{file}_{tm}_{fsize}{ext}'

if 'k' in fsize.lower():
    unit = float(1024)
    fsizecal = unit * float(fsize.translate(DD))
elif 'm' in fsize.lower():
    unit = float(1048576)
    fsizecal = unit * float(fsize.translate(DD))
elif 'g' in fsize.lower():
    unit = float(1073741824)
    fsizecal = unit * float(fsize.translate(DD))
else:
    print("For Kilobytes please use kb or k\nFor Megabytes please use mb or m\nFor Gigabytes please use gb or g")
    go = False

if go:
    os.system(f'fsutil.exe file createnew {outputdirectory}{fname} {int(fsizecal)}')