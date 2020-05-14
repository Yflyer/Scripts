#!/usr/bin/env python
# -*- coding:utf-8 -*-
# make a mapping when R1&R2 given.
# Yufei, 2019/12/21

import os
import sys

# use listdir to get files names
file1 = sys.argv[1]
file2 = sys.argv[2]

f1paths = os.listdir(file1)

f2paths = os.listdir(file2)

f1paths.sort()
f2paths.sort()

try:
    manifest = open ('mapping.tsv','w')
    manifest.write('#SampleID'+'\t'+'forward-absolute-filepath'+'\t'+'reverse-absolute-filepath'+'\n')
except IOError:
    print ("Can not create mapping, please check")
for (f1path,f2path) in zip(f1paths,f2paths):
    if f1path == f2path:
        sample = f1path
        manifest.write(sample+'\t'+'$PWD/'+file1+'/'+f1path+'\t'+'$PWD/'+file2+'/'+f2path+'\n')

print ('Mapping generated. Please check whether the mapping is right')
