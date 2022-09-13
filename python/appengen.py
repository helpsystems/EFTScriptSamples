from datetime import date

time = date.today()

ln = input('What do you want the logger name to be?: ')
an = input('What do you want the appender name to be?: ')
ran = input('What is the real appender name in the EFT logging.cfg? Case sensitive!: ')
ll = input('What level do you want the logging to be?: ')
pre_str = 'log4cplus.appender.'

l1 = f'\n#{ln} logger {time}\n'
l2 = f'{pre_str}{an.lower()}=log4cplus::RollingFileAppender'
l3 = f'{pre_str}{an.lower()}.File=${{AppDataPath}}\\EFT-{ln}.log'
l4 = f'{pre_str}{an.lower()}.MaxFileSize=20MB'
l5 = f'{pre_str}{an.lower()}.MaxBackupIndex=5'
l6 = f'{pre_str}{an.lower()}.layout=log4cplus::TTCCLayout'
l7 = f'{pre_str}{an.lower()}.layout.DateFormat=%m-%d-%y %H:%M:%S,%q'
l8 = f'log4cplus.additivity.{ran}=false'
l9 = f'log4cplus.logger.{ran}={ll.upper()}, {an.lower()}\n'

llist = [ l1, l2, l3, l4, l5, l6, l7, l8, l9]

for obj in llist:
    print(f'{obj}\r')