#!/usr/bin/env python
# -*- coding:utf-8 -*-
# make a mapping when R1&R2 given.
# Yufei, 2019/12/21
import re
import os
import sys

# use listdir to get files names
# e.g.,in 'X2016.1N',X is the tag. the length of sample names are not equal, so use a tag rather a fixed index are better.
file1=sys.argv[1]
file2=sys.argv[2]
# tag =  sys.argv[3]
f1paths = os.listdir(file1)
f2paths = os.listdir(file2)

### check completiness
if f1paths == f2paths:
    print('checked!')

samples = []
for file in f1paths:
    match = re.search(r'[_](\w+?)\W',file)
    if match:
        samples.append(match.groups()[0])


manifest = open ('mapping.tsv','w')
manifest.write('sample-id'+'\t'+'forward-absolute-filepath'+'\t'+'reverse-absolute-filepath'+'\n')
for (sample,f1path,f2path) in zip(samples,f1paths,f2paths):
    manifest.write(sample+'\t'+os.path.abspath(file1)+'/'+f1path+'\t'+os.path.abspath(file2)+'/'+f2path+'\n')
