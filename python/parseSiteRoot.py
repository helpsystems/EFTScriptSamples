#!/usr/bin/python3

import sys
import re
import string
from collections import defaultdict

currDir = ""

lines = []

folders = defaultdict(int)
foldersOldFiles = defaultdict(int)

parsedCurrentDir = []

while True:
	in_line = sys.stdin.readline()
	if not in_line:
		break

	in_line = in_line[:-1]
	  
	#m = re.search("Directory: (.*)$", in_line)
	m = re.search("gsbdata.InetPub.(.*)$", in_line)
	if m:
		currDir = m.group(1)
		currDir = currDir.lstrip().rstrip()

		# folder names split across lines
		while True:
			in_line = sys.stdin.readline()
			in_line = in_line[:-1]
			in_line = in_line.lstrip().rstrip()
			if(in_line == ''):
				break
			else:
				currDir = currDir + in_line

		#folders[currDir] = 0
		parsedCurrDir = re.split(r'\\', currDir)
		#print(currDir)
		continue

	#continue

	if in_line.startswith("-a----"):
		arr = re.split("\s+", in_line)
		filelen = int(arr[4]) #string.atoi(arr[4])
		for i in range(0, len(parsedCurrDir)):
			f = r'\\'.join(parsedCurrDir[0:i])
			folders[f] = folders[f] + filelen

		if arr[1].endswith("2019") or arr[1].endswith("2018"):
			for i in range(0, len(parsedCurrDir)):
				f = r'\\'.join(parsedCurrDir[0:i])
				foldersOldFiles[f] = foldersOldFiles[f] + filelen

for kv in folders.items():
	#print(kv)
	formattedOldFilesLen = "{:15d}".format(foldersOldFiles[kv[0]])
	formattedLen = "{:15d}".format(kv[1])
	if 0 != kv[1]:
		percent = 100.0 * float(foldersOldFiles[kv[0]])/float(kv[1])
	else:
		percent = float(0.0)

	line = "%s %s %s%% %s" % (formattedOldFilesLen, formattedLen, "{:6.2f}".format(percent), kv[0])
	lines.append(line)

lines.sort()
lines.reverse()
for line in lines:
	print(line)

