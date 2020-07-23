#!/usr/bin/env python
# -*- coding:utf-8 -*-
# make a mapping when R1&R2 given.
# Yufei, 2019/12/21

import os
import sys
import re

# use listdir to get files names: to extract sample names
raw_path = os.path.abspath(sys.argv[1]) # choose the seq file: 00_rawdata/
#raw_path_2 = os.path.abspath(sys.argv[4])
tag = sys.argv[2] # print a tag: X
#sample_len = int(sys.argv[3]) # the lenght start from tag of words: 6

input_list = os.listdir(raw_path)
input_list.sort()
input_list = iter(input_list)

try:
    manifest = open ('mapping.tsv','w')
    manifest.write('#SampleID'+'\t'+'forward-absolute-filepath'+'\t'+'reverse-absolute-filepath'+'\n')
except IOError:
    print ("Can not create mapping, please check")

for file in input_list:
    #print (file)
    match = re.search(r'{}(\w+?)\W'.format(tag),file)
    if match:
        sample = match.groups()[0]
        forwad_path = os.path.join(raw_path,file)
        backward_path = os.path.join(raw_path,next(input_list))
        manifest.write(sample+'\t'+forwad_path+'\t'+backward_path+'\n')

print ('Mapping generated. Please check whether the mapping is right')
