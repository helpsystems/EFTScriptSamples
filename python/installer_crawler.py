# Requirements
# Copy all of the files from the W:\Installers folder to any local folder on the laptop
# Build a manifest
# Determine the difference between the current W:\Installers and the destination manifest
# RSYNC?
# importing required packages
import os
from datetime import datetime
 
tm = now.strftime("X%mX%dX%y-X%HX%MX%S").replace('X0','X').replace('X','')
# defining source and destination
# paths
src = 'W:/installers'
trg = 'C:/Users/jbranan/Downloads/installers'
logfile = f'C:/Users/jbranan/Desktop/RC_log_{tm}.log'

os.system(f'Robocopy {src} {trg} /V /E /r:1 /w:15 /log+:{logfile}  /XO /NP')