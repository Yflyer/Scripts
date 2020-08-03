#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei, 5/24/2020, zengyf93@qq.com
import time
import os
import sys
import argparse

def get_parser():
    parser = argparse.ArgumentParser(description="This script can check format of pair-end data and then pair them by correct reads label. The unpaired or uncompleted data will be discarded by this script.")
    parser.add_argument('--r1',required=True,help='the fold path of fastq')
    parser.add_argument('--r2',required=True,help='the fold path of fastq')
    parser.add_argument('--output',default='01_cleandata',help='output')
    return parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    r1 = args.r1
    r2 = args.r2
    output = args.output

r1_list = [os.path.join(r1,file) for file in os.listdir(r1)]
r2_list = [os.path.join(r2,file) for file in os.listdir(r2)]
check_r1_list = [os.path.join(output,'r1',file) for file in os.listdir(r1)]
check_r2_list = [os.path.join(output,'r2',file) for file in os.listdir(r2)]


for (raw_r1,raw_r2,check_r1,check_r2) in zip(r1_list,r2_list,check_r1_list,check_r2_list):
    dict1 = {}
    with open(raw_r1,'r') as f:
        for line in f:
            if ' ' in line:
                key=line[:line.index(' ')]
            else:
                key=line.strip()
            try:
                #line[0] = '@'
                # seq check
                seq = next(f)
                seq = seq.upper().strip()+'\n'
                # link check
                link = next(f)
                link = '+\n'
                # qc length check
                qc = next(f)
                if len(qc)!= len(seq): # this comparision included '\n'
                    if len(qc)>len(seq): qc=qc[:len(seq)-1]+'\n'
                    if len(seq)>len(qc): seq=seq[:len(qc)-1]+'\n'

                dict1[key]=line+seq+link+qc
            except:
                print ('### warning:{} / {} is uncompleted. This seq has been discarded'.format(raw_r1,key))
                continue

    dict2 = {}
    with open(raw_r2,'r') as f:
        for line in f:
            if ' ' in line:
                key=line[:line.index(' ')]
            else:
                key=line.strip()
            try:
                #line[0] = '@'
                # seq check
                seq = next(f)
                seq = seq.upper().strip()+'\n'
                # link check
                link = next(f)
                link = '+\n'
                # qc length check
                qc = next(f)
                if len(qc)!= len(seq): # this comparision included '\n'
                    if len(qc)>len(seq): qc=qc[:len(seq)-1]+'\n'
                    if len(seq)>len(qc): seq=seq[:len(qc)-1]+'\n'

                dict2[key]=line+seq+link+qc
            except:
                print ('### warning:{}: {} is uncompleted. This seq has been discarded'.format(raw_r2,key))
                continue

    if dict1.keys() != dict2.keys():
        print('### {} and {} are not paired. Now pairing.....'.format(raw_r1,raw_r2))
        # get the intersect (pair)
        pair_intersect = dict1.keys() & dict2.keys()

        if not pair_intersect:
           print("No seqs can be paired. Something is wrong to pair your sample.")
           break

        with open(check_r1,'w') as f:
            for x in pair_intersect:
                f.write(dict1[x])

        with open(check_r2,'w') as f:
            for x in pair_intersect:
                f.write(dict2[x])
    else:
        with open(check_r1,'w') as f:
            for key1 in dict1:
                f.write(dict1[key1])

        with open(check_r2,'w') as f:
            for key2 in dict2:
                f.write(dict2[key2])

    print('{} and {} has been paired'.format(raw_r1,raw_r2))
