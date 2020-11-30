#!/usr/bin/env python
# -*- coding:utf-8 -*-
# for data from IEG
# use like: split_by_tag.py merge.fastq split_dir --
# if you have a merged r1 and a merged r2, just run the script twice......
# Yufei, 2019/12/21

import os
import sys
import re

def mkdir(path):
	if not os.path.exists(path):
		os.makedirs(path)
		print ("--- Create a new directory ---")
	else:
		print ("--- The directory has already existed! ---")

# saved path (dir)
file = open (sys.argv[1],'r')
fdir = sys.argv[2] # merge fastq file
tag = sys.argv[3] # output directory
mkdir(fdir)

for line in file:
    match = re.search(r'{}(\w+?)\W'.format(tag),line) # match tags by RegExp ***
    if match:
        #print ('found', match.group()) ## found tags
        #print(match.groups()[0])
        fastq = open('{}/{}.fastq'.format(fdir,match.groups()[0]),'a')
        try:
            fastq.write(line)
            for i in range(3): fastq.write(next(file))
        except IOError:
            print ("Error: this read can not be written. Skiped it.")
	#else:
		#print ("--- No tag can be matched! ---")

file.close()

print('Completed!')
