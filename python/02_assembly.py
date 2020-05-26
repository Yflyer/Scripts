#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei, 5/24/2020, zengyf93@qq.com
import time
import os
import sys
import psutil
import shutil

start = time.time()
Pj_path = os.getcwd()

out_path = os.path.join(Pj_path,'02_contigs')
in_path = sys.argv[1] # 01_cleandata
memory = sys.argv[2] # 0.5
threads = int(sys.argv[3]) # 6
rm_temp = sys.argv[4] # True

kmin = 21
kmax = 121
kstep = 10
hostrm = False

# create trim path
if not os.path.exists(out_path):
    os.mkdir(out_path)
    print('*** The output result will be in "{}" ***'.format(out_path))
else:
    print('*** The output result will be in "{} ***"'.format(out_path))

in_list = os.listdir(in_path)
print (in_list)
for sample in in_list:
    out_path_sample = os.path.join(out_path,sample)
    if os.path.exists(out_path_sample):
        shutil.rmtree(out_path_sample)

    clean_r1 = in_path +'/'+ sample +'/'+ sample + '_R1.Trimmed.fq.gz'
    clean_r2 = in_path +'/'+ sample +'/'+ sample + '_R2.Trimmed.fq.gz'
    print ("*** Working on sample {} ***".format(sample))
    assemble='''megahit --k-min {kmin} --k-max {kmax}  --k-step {kstep} -m {memory} -t {threads} -1 {clean_r1} -2 {clean_r2} -o {out_path_sample} --out-prefix {sample} && echo \"Assembly_Done!\"
    '''.format(kmin=kmin,kmax=kmax,kstep=kstep,memory=memory,threads=threads,clean_r1=clean_r1,clean_r2=clean_r2,out_path_sample=out_path_sample,sample=sample)
    os.system(assemble)
    if rm_temp: shutil.rmtree('{}/intermediate_contigs'.format(out_path_sample))

os.system('n50 -b {}/*/*.contigs.fa --format tsv > 02_N50_result.tsv'.format(out_path))
print ('*** Contigs N50 generated. ***')
print ('*** {} is completed. ***'.format(os.path.basename(__file__)))

end = time.time()
print("*** Comsuming time:{}. ***".format(end-start))
