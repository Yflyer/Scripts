#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei, 5/24/2020, zengyf93@qq.com
import time
import os
import sys
import argparse
#import fileinput

def get_parser():
    parser = argparse.ArgumentParser(description="This script is used to unify the fastq format which may be wrong before downstream analysis")
    parser.add_argument('--input',required=True,help='the fold path of fastq')
    parser.add_argument('--output',required=True,help='the checked output folder of fastq')

    return parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    input = args.input
    output = args.output

input_list = [os.path.join(input,file) for file in os.listdir(input)]
output_list = [os.path.join(output,file) for file in os.listdir(input)]
#print(input_list)
#print(output_list)

if not os.path.exists(output):
    os.mkdir(output)
    print('*** The output result will be in "{}" ***'.format(output))
else:
    print('*** The output result will be in "{} ***"'.format(output))

for (raw,check) in zip(input_list,output_list):
   raw_f = open (raw,'r')
   check_f = open (check,'w')
   num=1
   for line in raw_f:
       # title check
       if line[0] != '@':
           line[0] = '@'
           print ('Line {} title wrong in {}'.format(num,raw))
       tag = line.strip() +'\n'

       # seq check
       seq = next(raw_f)
       num = num+1
       if not seq.isupper(): print ('Line {} seq wrong in {}'.format(num,raw))
       seq = seq.upper().strip()+'\n'

       # link check
       link = next(raw_f)
       num = num+1
       if link != '+\n': print ('Line {} link wrong in {}'.format(num,raw))
       link = '+\n'


       # qc check: lenght check
       qc = next(raw_f)
       num = num+1
       if len(qc)!= len(seq):print ('Line {} qc wrong in {}'.format(num,raw))
       if len(qc)>len(seq): qc=qc[:(len(qc)-len(seq))].strip()+'\n'
       if len(seq)>len(qc): seq=seq[:(len(seq)-len(qc))].strip()+'\n'

       check_f.write(tag+seq+link+qc)
       num = num+1

   print('Check of {} done'.format(raw))
   raw_f.close()
   check_f.close()
