#!/usr/bin/env python
# -*- coding:utf-8 -*-
import argparse

def get_parser():
    parser = argparse.ArgumentParser(description="Demo of argparse")
    parser.add_argument('--input', required=True,help='input')
    parser.add_argument('--output',default='01_cleandata',help='output')
    parser.add_argument('--adapter', type=str,default='TruSeq3-PE.fa',help='adapter')
    parser.add_argument('--threads', type=int,default='4',help='threads')
    parser.add_argument('--kmin',type=int,default='21',help='kmin')

    return parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    map = args.input
    adapter = args.adapter
    threads = args.threads
    trim_path = args.output
    print(map,type(map))
    print(adapter,type(adapter))
    print(trim_path,type(adapter))
