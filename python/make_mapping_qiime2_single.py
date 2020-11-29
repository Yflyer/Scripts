#!/usr/bin/env python
# -*- coding:utf-8 -*-
# make a mapping when single-end given.
# Yufei, 2020/11/14
# use when you have splited data (sample1.fastq, sample2.fastq......),not for merged SampleData
# save all sample fastq in one file, like file1
# then commmand: make_mapping_qiime2.py file1
# you will get a mapping.tsv, for qiime2 data import
# don't forget to check whether it is right

import re
import os
import sys

# use listdir to get files names

file1=sys.argv[1]
#file2=sys.argv[2]
# tag =  sys.argv[3]
f1paths = os.listdir(file1)
#f2paths = os.listdir(file2)

'''if f1paths == f2paths:
    print('checked!')'''

samples = []
for file in f1paths:
    match = re.search(r'(\w+?)\W',file)
    if match:
        samples.append(match.groups()[0])


manifest = open ('mapping.tsv','w')
manifest.write('sample-id'+'\t'+'absolute-filepath'+'\n')
for (sample,f1path) in zip(samples,f1paths):
    manifest.write(sample+'\t'+os.path.abspath(file1)+'/'+f1path+'\n')
