#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei, 6/21/2021, zengyf93@qq.com
import os
import sys
import argparse


def get_parser():
    parser = argparse.ArgumentParser(description="Demo of argparse")
    parser.add_argument('--ID', required=True,help='ID list text file')
    parser.add_argument('--fa',default='target.fast',help='fast file you want to extract')
    parser.add_argument('--output',default='extracted.fasta',help='extracted file of fasta')
    return parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    fa = args.fa
    ID = args.ID
    output = args.output

dict1 = {}
with open(fa,'r') as f:
    for line in f:
        key=line.strip('>')
        seq = next(f)
        dict1[key]=seq

ID_list = open (ID,'r')
ID_list = ID_list.readlines()
print(ID_list)

pair_dict1 = {x:dict1[x] for x in dict1.keys() if x in dict2.keys()}
