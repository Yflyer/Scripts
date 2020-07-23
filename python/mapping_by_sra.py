#!/usr/bin/env python
# -*- coding:utf-8 -*-
# make a mapping of sra
# Yufei, 2019/12/21
import re
import os
import sys
import argparse

def get_parser():
    parser = argparse.ArgumentParser(description="Demo of argparse")
    parser.add_argument('--sra',required=True,help='--sra-meta')
    parser.add_argument('--input',required=True,help='--input')
    parser.add_argument('--output',default='mapping',help='output')
    parser.add_argument('--format',default='csv',help='output')
    parser.add_argument('--type',default='16S',help='sequence 16S')
    return parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    map = args.sra
    input = args.input
    output = args.output
    type = args.type
    if args.format == 'csv':
        sep = ','
    elif args.format == 'tsv' or 'txt':
        sep = '\t'

manifest = open ((output+'.{}'.format(args.format)),'w')
manifest.write('sample-id'+sep+'forward-absolute-filepath'+sep+'reverse-absolute-filepath'+'\n')

with open (map,'r') as mapping:
    print ("*** Loading sra-meta information ***")
    meta = mapping.readline().strip().split(sep)
    print(meta)
    SRR_index = meta.index('Run')
    sample_index = meta.index('Sample Name')
    pair_index = meta.index('LibraryLayout')
    lib_type = meta.index('Library Name')

    for line in mapping:
        line = line.strip().split(sep)
        print(line)
        print(sample_index)
        print(line[sample_index])
        if line[pair_index] == 'PAIRED' and type in line[lib_type]:
            sample = line[sample_index]
            f1path = line[SRR_index]+'_1.fastq'
            f2path = line[SRR_index]+'_2.fastq'
            input_path = os.path.abspath(input)
            manifest.write(sample+sep+os.path.abspath(input_path)+'/'+f1path+sep+os.path.abspath(input_path)+'/'+f2path+'\n')
        elif line[pair_index] == 'SINGLE' and type in line[lib_type]:
            sample = line[sample_index]
            f1path = line[SRR_index]+'.fastq'
            input_path = os.path.abspath(input)
            manifest.write(sample+sep+os.path.abspath(input_path)+'/'+f1path+'\n')
        #else:
            #print('The pair-or-not of sample {} is not clear'.format(line[sample_index]))
