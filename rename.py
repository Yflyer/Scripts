#！/usr/bin/python3.6
# -*- coding:utf-8 -*-
# use like: tag_split merge.fastq split_dir
import os,sys

#查找文件
path=sys.argv[1]
#os.listdir()方法，列出来所有文件
#返回path指定的文件夹包含的文件或文件夹的名字的列表

files=os.listdir(path)

#主逻辑
#对于批量的操作，使用FOR循环
for f in files:
	new_name = f.replace('-','_')
	new_name = './'+path+'/'+new_name
	f = './'+path+'/'+f
	#print(new_name)
	#print(f)
	os.rename(f,new_name)
