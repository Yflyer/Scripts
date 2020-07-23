#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei, 5/24/2020, zengyf93@qq.com
import time
import os
import sys
import psutil
import shutil
import argparse

start = time.time()
Pj_path = os.getcwd()

def get_parser():
    parser = argparse.ArgumentParser(description="Demo of argparse")
    parser.add_argument('-i','--input',required=True,help='input')
    parser.add_argument('-o','--output',default='01_assembly',help='output')
    parser.add_argument('-m','--memory', type=float,default=250,help='memory')
    parser.add_argument('-t','--threads', type=int,default=4,help='threads')
    parser.add_argument('--rmtemp',default=False,help='rmtemp')
    parser.add_argument('--kmin',default=21,help='kmin')
    parser.add_argument('--kmax',default=121,help='kmin')
    parser.add_argument('--kstep',default=10,help='kstep')
    parser.add_argument('--suffix',required=False,default='spades',help='suffix')
    return parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    in_path = args.input
    if args.suffix:
        out_path = args.output+'_'+args.suffix
    else:
        out_path = args.output
    memory = args.memory
    threads = args.threads
    rm_temp = args.rmtemp
    kmin = args.kmin
    kmax = args.kmax
    kstep = args.kstep

'''out_path = os.path.join(Pj_path,'02_contigs')
in_path = sys.argv[1] # 01_cleandata
memory = sys.argv[2] # 0.5
threads = int(sys.argv[3]) # 6
rm_temp = sys.argv[4] # True'''

# create trim path
if not os.path.exists(out_path):
    os.mkdir(out_path)
    print('*** The output result will be in "{}" ***'.format(out_path))
else:
    print('*** The output result will be in "{} ***"'.format(out_path))

in_list = os.listdir(in_path)
print ('***',in_list,'***')
for sample in in_list:
    out_path_sample = os.path.join(out_path,sample)
    if os.path.exists(out_path_sample):
        shutil.rmtree(out_path_sample)

    clean_r1 = in_path +'/'+ sample +'/'+ sample + '_R1.Trimmed.fq.gz'
    clean_r2 = in_path +'/'+ sample +'/'+ sample + '_R2.Trimmed.fq.gz'
    print ("*** Working on sample {} ***".format(sample))
    assemble='''metaspades.py -1 {clean_r1} -2 {clean_r2} -o {out_path_sample} -t {threads} && echo \"Assembly_Done!\"'''.format(kmin=kmin,kmax=kmax,kstep=kstep,memory=memory,threads=threads,clean_r1=clean_r1,clean_r2=clean_r2,out_path_sample=out_path_sample,sample=sample)
    os.system(assemble)

#if rm_temp: os.system('rm -rf {}/*/intermediate_contigs'.format(out_path))
print ('*** temp files were deleted. ***')
os.system('n50 $(ls {out_path}/*/*.fasta) --format tsv > {out_path}/metaSpades_N50_result.tsv'.format(out_path=out_path))
print ('*** Contigs N50 generated. ***')
print ('*** {} is completed. ***'.format(os.path.basename(__file__)))

end = time.time()
print("*** Comsuming time:{}. ***".format(end-start))
