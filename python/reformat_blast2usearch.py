#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei, 5/24/2020, zengyf93@qq.com
import time
import os
import sys
import argparse
#import fileinput

def get_parser():
    parser = argparse.ArgumentParser(description="reformat the BLAST fasta format (>seq label + multi-line of seq) to Usearch database version")
    parser.add_argument('--input',required=True,help='BLAST fasta file')
    parser.add_argument('--output',required=True,help='Usearch fasta file')
    return parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    input = args.input
    output = args.output

input_f = open (input,'r')
#print(input_f)
fasta = iter(input_f.readlines())
input_f.close()
output_f = open (output,'w')
print('------------note: the level defined by usearch can not work for Eukaryota levels of SILVA annoation----------------')
print('------------note: this script only selects the annotated taxanomy at least over 4 levels----------------')

num=1
seq=None
keep_this_seq=True
for line in fasta:
    if line[0] == '>':
        '''
        #if seq is not None and keep_this_seq:
        #    output_f.write(seq+'\n')
        ###else:
            ###print('discard')
        '''
        # label reformat
        label = line.strip()
        tag= label.split(' ')[0]
        # there is a bug:if you use strip(tag+' '), a extra letter of tax will be deleted, so I have to strip twice
        # need to remove comma in line for usearch prase
        tax = label.strip(tag).strip().replace(',', '-').split(';')
        # Euk will be wrong in Usearch level, so it need to be excluded in downstream analysis
        try:
            if 'Eukaryota' in tax[0]:
                tax[0]='(Should be excluded)'+tax[0]

            if len(tax) >= 7:
                tax=';tax=d:'+tax[0]+',p:'+tax[1]+',c:'+tax[2]+',o:'+tax[3]+',f:'+tax[4]+',g:'+tax[5]+',s:'+tax[6]
            elif len(tax) == 6:
                tax=';tax=d:'+tax[0]+',p:'+tax[1]+',c:'+tax[2]+',o:'+tax[3]+',f:'+tax[4]+',g:'+tax[5]
            elif len(tax) == 5:
                tax=';tax=d:'+tax[0]+',p:'+tax[1]+',c:'+tax[2]+',o:'+tax[3]+',f:'+tax[4]
            elif len(tax) <= 4:
                tax=';tax=d:'+tax[0]+',p:'+tax[1]+',c:'+tax[2]+',o:'+tax[3]

            label=tag+tax+';\n'
            output_f.write(label)
            keep_this_seq=True

        except Exception as e:
            keep_this_seq=False
            print('---------',e,':the seq {} will be discarded'.format(tag),'---------')
            #print('Wrong sea tag of taxanonmy info:',tag)
            print('Wrong index of taxanonmy info:',tax)
            #print(num)

        '''
        #seq = next(fasta).strip()
        #print(label)
        #num = num+1
        #print(num)
        '''

    else:
        # seq refomrat from multi line to one line
        #seq = seq+line.strip()
        if keep_this_seq:
            output_f.write(line)
        num = num+1
        #print(num)

#output_f.write(seq+'\n')
print('------------fasta seqs are reformatted----------------')
output_f.close()
