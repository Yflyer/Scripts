#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei,2020

import os,sys

#查找文件
#the input is the relative path of directory
path = sys.argv[1]
tag = sys.argv[2]
output = sys.argv[3]

files=os.listdir(path)

dict1 = {}
#use os.path to check file
for sample in files:
    with open(os.path.join(path,sample),'r') as f:
        for line in f:
            key=line.strip()
            title = key + ' ' + tag + sample[:sample.index('.')] +'\n'
            seq = next(f)
            dict1[key]=title+seq

with open(output,'w') as f:
    for key in dict1:
        f.write(dict1[key])
