#!/usr/bin/env python
# -*- coding:utf-8 -*-
# use like: tag_split merge.fastq split_dir
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
fdir = sys.argv[2]
tag = sys.argv[3]
mkdir(fdir)

for line in file:
    match = re.search(r'{}(\w+?)\W'.format(tag),line) # match tags by re ***
    if match:
        #print ('found', match.group()) ## found tags
        #print(match.groups()[0])
        fastq = open('{}/{}.fastq'.format(fdir,match.groups()[0]),'a')
        fastq.write(line)
        for i in range(3): fastq.write(next(file))
    else:
        print ('did not find tags from ',line[0:6],line[-6:len(line)])
        break

file.close()

print('Completed!')
