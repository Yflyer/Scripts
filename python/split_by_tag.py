#！/usr/bin/python3.6
# -*- coding:utf-8 -*-

import re
import os
import sys

def mkdir(path): # waiting for be moved into base tools
	folder = os.path.exists(path)
	if not folder:
		os.makedirs(path)
		print ("--- Create a new directory ---")
	else:
		print ("--- The directory has already existed! ---")


f = open (sys.argv[1],'r')
fdir = sys.argv[2]
mkdir(fdir)

line = f.readline()

while line:
    match = re.search(r'--\w{5,6}', line) # match tags by re ***
    if match:
        #print ('found', match.group()) ## found tags
        fastq = open('{}/{}.fastq'.format(fdir,match.group()),'a')
        fastq.write(line)
        for i in range(3): fastq.write(f.readline())
    else:
        print ('did not find tags from ',line[0:6],line[-6:len(line)])
    line = f.readline()
f.close()
