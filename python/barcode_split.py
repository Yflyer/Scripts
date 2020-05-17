#!/usr/bin/env python
# -*- coding:utf-8 -*-
# use like: tag_split merge.fastq split_dir

import re
import os
import sys
import csv

def mkdir(path): # waiting for be moved into base tools
    folder = os.path.exists(path)
    if not folder:
        os.makedirs(path)
        print ("--- Create a new directory ---")
    else:
        print ("--- The directory has already existed! ---")

# saved path (dir)
fdir = sys.argv[3]
mkdir(fdir)
mkdir(fdir+'/r1')
mkdir(fdir+'/r2')

# I/O in low-memory consuming
with open ('{}'.format(sys.argv[1]),'r') as file:
    fastq = file.readlines()
    map = open('{}'.format(sys.argv[2]),'r').readlines()
    for line in map:
        sample = line.strip().split('\t')[0]
        barcode = line.strip().split('\t')[1]
        spilt_r1 = open('{}/r1/{}.fastq'.format(fdir,sample),'a')
        spilt_r2 = open('{}/r2/{}.fastq'.format(fdir,sample),'a')
        for num, seq in enumerate(fastq):
            seq = seq.split('\t')
            if barcode in seq[1][0:12]:
                r1_fq = '\n'.join(seq[0:4])
                r2_fq = '\n'.join(seq[4:8])
                spilt_r1.write(r1_fq+'\n')
                spilt_r2.write(r2_fq)
                #print(r1_fq)

file.close()
