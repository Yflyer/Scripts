#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei,2020

import os,sys

#查找文件
#the input is the relative path of directory
path = sys.argv[1]
old_tag = sys.argv[2]
new_tag = sys.argv[3]

files=os.listdir(path)

#use os.path to check file
for f in files:
    if old_tag in f:
        print("Previous name:{}".format(f))
        old_file=os.path.join(path,f)
        new_file=os.path.join(path,f.replace(old_tag,new_tag))
        os.rename(old_file,new_file)
        print("Now:{}".format(f.replace(old_tag,new_tag)))
