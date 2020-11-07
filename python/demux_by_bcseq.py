#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei, 5/24/2020, zengyf93@qq.com
import time
import os
import sys
import argparse


def get_parser():
    parser = argparse.ArgumentParser(description="Demo of argparse")
    parser.add_argument('--bcsample', required=True,help='barcode')
    parser.add_argument('--r1', required=True,help='R1.FASTQ')
    parser.add_argument('--r2', required=True,help='R2.FASTQ')
    parser.add_argument('--bcseq', required=True,help='barcode')
    parser.add_argument('--lenlim', default=30,help='detect limit length')
    parser.add_argument('--output',default='split_seq',help='output-FOLDER')
    parser.add_argument('--tag',default='--',help='output')
    parser.add_argument('--format',default='txt',help='output')
    return parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    bcsample = args.bcsample
    r1 = args.r1
    r2 = args.r2
    bcseq = args.bcseq
    lenlim = args.lenlim
    seq_index = 5
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


# create pair file of three demux seq
#
pair_dict = {}
with open(r1, 'r') as R1, open(r2, 'r') as R2, open(bcseq, 'r') as bc_seq:
    for (line1,line2,line3) in zip(R1,R2,bc_seq): # zip only used in py >3.3
        pair = [line1,line2,line3]
        for i in range(3):
            other = next(zip(R1,R2,bc_seq))
            pair.extend(list(other))
        pair_dict[line1] = pair

print('reads indexed pairly.')

bc_dict = {}
with open (bcsample,'r') as bc:
    for line in bc:
        sample,barcode_seq = line.strip().split(sep)
        bc_dict[sample] = barcode_seq

print('{} sample waiting for match their barcodes'.format(len(bc_dict.keys())))
print('{} of reads waiting for match'.format(len(pair_dict.keys())))

for sample in bc_dict.keys():
    split_r1 = open('{}/{}_R1.fastq'.format(output,sample), 'w')
    split_r2 = open('{}/{}_R2.fastq'.format(output,sample), 'w')
    num = 0
    #print(bc_dict[sample])
    for read in pair_dict.keys():
        #print(pair_dict[read][seq_index][:lenlim])
        if bc_dict[sample] in pair_dict[read][3]:
            #split_r1.write(pair_dict[0]+pair_dict[1])
            num += 1
        if bc_dict[sample] in pair_dict[read][4]:
            #split_r1.write(pair_dict[0]+pair_dict[1])
            num += 1
        if pair_dict[read][5][1:11] in bc_dict[sample]:
            #split_r1.write(pair_dict[0]+pair_dict[1])
            num += 1
    print('{} reads match in {}'.format(num,sample))
