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

with open('{}/{}_R1.fastq'.format(output,output), 'a') as R1, open (map,'r') as mapping:
    print ("*** Loading mapping information ***")
    next(mapping)
    for line in mapping:
        sample,forward_fq= line.strip().split(sep)
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

            for key1 in dict1:
                R1.write(dict1[key1])

        print('{} are paired and merged successfully'.format(sample))
