#!/usr/bin/env python
# -*- coding:utf-8 -*-
# make a mapping when R1&R2 given.
# Yufei, 2019/12/21

import os
import sys

# use listdir to get files names
raw_path = os.path.abspath(sys.argv[1])
tag = sys.argv[2]
sample_len = int(sys.argv[3])

input_list = iter(os.listdir(raw_path))
#input_list.sort()

try:
    manifest = open ('mapping.tsv','w')
    manifest.write('#SampleID'+'\t'+'forward-absolute-filepath'+'\t'+'reverse-absolute-filepath'+'\n')
except IOError:
    print ("Can not create mapping, please check")

for file in input_list:
    sample = file[file.index(tag):sample_len]
    forwad_path = os.path.join(raw_path,file)
    backward_path = os.path.join(raw_path,next(input_list))
    manifest.write(sample+'\t'+forwad_path+'\t'+backward_path+'\n')

print ('Mapping generated. Please check whether the mapping is right')
