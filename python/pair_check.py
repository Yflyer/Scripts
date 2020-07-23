#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei, 5/24/2020, zengyf93@qq.com
import time
import os
import sys
import psutil
import argparse

def get_parser():
    parser = argparse.ArgumentParser(description="Demo of argparse")
    parser.add_argument('--input', required=True,help='input')
    parser.add_argument('--output',default='01_cleandata',help='output')
    return parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    map = args.input

#str1 = '@M01056:129:000000000-ADADM:1:1105:2427:19573--11_13N_N_N_0\n'

with open (map,'r') as mapping:
    print ("*** Loading mapping information ***")
    next(mapping)
    for line in mapping:
        sample,forward_fq,backward_fq = line.strip().split('\t')
        dict1 = {}
        with open(forward_fq,'r') as f:
            for line in f:
                if ' ' in line:
                    key=line[:line.index(' ')]
                else:
                    key=line.strip()
                tag = line
                seq = next(f)
                link = next(f)
                qc = next(f)
                dict1[key]=line+seq+link+qc

        dict2 = {}
        with open(backward_fq,'r') as f:
            for line in f:
                if ' ' in line:
                    key=line[:line.index(' ')]
                else:
                    key=line.strip()
                tag = line
                seq = next(f)
                link = next(f)
                qc = next(f)
                dict2[key]=line+seq+link+qc

        if dict1.keys() != dict2.keys(): print('{} is not paired'.format(sample))

        pair_dict1 = {x:dict1[x] for x in dict1.keys() if x in dict2.keys()}
        pair_dict2 = {x:dict2[x] for x in dict2.keys() if x in dict1.keys()}

        if not pair_dict1 or not pair_dict2:
            print("No seqs can be paired. Something is wrong to pair your sample.")
            break

        if pair_dict1.keys() == pair_dict2.keys(): print('{} has been paired'.format(sample))

        with open(forward_fq,'w') as f:
            for key1 in pair_dict1:
                f.write(pair_dict1[key1])

        with open(backward_fq,'w') as f:
            for key2 in pair_dict2:
                f.write(pair_dict2[key2])
