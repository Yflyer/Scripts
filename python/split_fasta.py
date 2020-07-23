#!/usr/bin/env python
# -*- coding:utf-8 -*-
# use like: tag_split merge.fastq split_dir
# Yufei, 2019/12/21
# this script only used for hawaii data

import os
import sys
import re

def mkdir(path):
	if not os.path.exists(path):
		os.makedirs(path)
		print ("--- Create a new directory ---")
	else:
		for file in os.listdir(path):
			os.remove(os.path.join(path, file))
		print ("--- The directory has already existed! ---")

# saved path (dir)
file = open (sys.argv[1],'r')
fdir = sys.argv[2]
tag = sys.argv[3]
mkdir(fdir)

a_num=0
b_num=0
# the indent must be wrong
for line in file:
	if '.30.' not in line[10]:
			match = re.search(r'{}(\w+?.\w+?)\W'.format(tag),line)
			sample = match.groups()[0].replace('.','_')
			id = line.strip().split(' ')[1]
			fastq=open('{}/{}.fasta'.format(fdir,sample),'a')
        		fastq.write('>'+id+'\n')
        		fastq.write(next(file))
			a_num += 1
	else:
		b_num +=1
		next(file)

file.close()

print('{} reads used, {} reads remove'.format(a_num,b_num))
