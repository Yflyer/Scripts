#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei, 5/24/2020, zengyf93@qq.com
import time
import os
import sys
import argparse


def get_parser():
    parser = argparse.ArgumentParser(description="Demo of argparse")
    parser.add_argument('--input', required=True,help='input')
    parser.add_argument('--output',default='merge_seq',help='output')
    parser.add_argument('--tag',default='--',help='output')
    parser.add_argument('--format',default='csv',help='output')
    return parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    map = args.input
    output = args.output
    tag = args.tag
    if args.format == 'csv':
        sep = ','
    elif args.format == 'tsv' or 'txt':
        sep = '\t'

if not os.path.exists(output):
    os.mkdir(output)
    print('*** The output result will be in "{}" ***'.format(output))
else:
    print('*** {} has been already existed, please deleted extra R1 or R2 to avoid overwritten ***"'.format(output))

with open('{}/{}_R1.fastq'.format(output,output), 'a') as R1, open('{}/{}_R2.fastq'.format(output,output), 'a') as R2, open (map,'r') as mapping:
    print ("*** Loading mapping information ***")
    next(mapping)
    for line in mapping:
        sample,forward_fq,backward_fq = line.strip().split(sep)
        dict1 = {}
        with open(forward_fq,'r') as f:
            for line in f:
                if ' ' in line:
                    key=line[:line.index(' ')]
                else:
                    key=line.strip()
                title = key + ' ' + tag + sample +'\n'
                seq = next(f)
                link = next(f)
                link = '+\n'  # it need to check necessity again in other sra data
                qc = next(f)
                dict1[key]=title+seq+link+qc

        dict2 = {}
        with open(backward_fq,'r') as f:
            for line in f:
                if ' ' in line:
                    key=line[:line.index(' ')]
                else:
                    key=line.strip()
                title = key + ' ' + tag + sample +'\n'
                seq = next(f)
                link = next(f)
                link = '+\n' # it need to check necessity again in other sra data
                qc = next(f)
                dict2[key]=title+seq+link+qc

        if dict1.keys() != dict2.keys():
            print('{} is not paired'.format(sample))
            pair_dict1 = {x:dict1[x] for x in dict1.keys() if x in dict2.keys()}
            pair_dict2 = {x:dict2[x] for x in dict2.keys() if x in dict1.keys()}

            if not pair_dict1 or not pair_dict2:
                print("No seqs can be paired. Something is wrong to pair your sample.")
                break

            if pair_dict1.keys() == pair_dict2.keys(): print('{} has been paired'.format(sample))

            for key1 in pair_dict1:
                R1.write(pair_dict1[key1])
            for key2 in pair_dict2:
                R2.write(pair_dict2[key2])

        else:
            for key1 in dict1:
                R1.write(dict1[key1])
            for key2 in dict2:
                R2.write(dict2[key2])

        print('{} are paired and merged successfully'.format(sample))
