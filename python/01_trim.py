#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei, 5/24/2020, zengyf93@qq.com
import time
import os
import sys
import psutil
import argparse

start = time.time()

def get_parser():
    parser = argparse.ArgumentParser(description="Demo of argparse")
    parser.add_argument('--input', required=True,help='input')
    parser.add_argument('--output',default='01_cleandata',help='output')
    parser.add_argument('--adapter', type=str,default='TruSeq3-PE.fa',help='adapter')
    parser.add_argument('--threads', type=int,default=4,help='threads')
    parser.add_argument('--rmtemp',default=False,help='rmtemp')

    return parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    map = args.input
    adapter = args.adapter
    threads = args.threads
    trim_path = args.output
    rm_temp = args.rmtemp
# create adapter file
with open(adapter,'w') as adapter_file:
    if adapter == 'TruSeq2-PE.fa':
        adapter_file.write('''>PrefixPE/1
AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT
>PrefixPE/2
CAAGCAGAAGACGGCATACGAGATCGGTCTCGGCATTCCTGCTGAACCGCTCTTCCGATCT
>PCR_Primer1
AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT
>PCR_Primer1_rc
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT
>PCR_Primer2
CAAGCAGAAGACGGCATACGAGATCGGTCTCGGCATTCCTGCTGAACCGCTCTTCCGATCT
>PCR_Primer2_rc
AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAGACCGATCTCGTATGCCGTCTTCTGCTTG
>FlowCell1
TTTTTTTTTTAATGATACGGCGACCACCGAGATCTACAC
>FlowCell2
TTTTTTTTTTCAAGCAGAAGACGGCATACGA''')
        print ("*** Adapter generated ***")
    elif adapter == 'TruSeq3-PE.fa':
        adapter_file.write('''>PrefixPE/1
TACACTCTTTCCCTACACGACGCTCTTCCGATCT
>PrefixPE/2
GTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT''')
        print ("*** Adapter generated ***")
    else:
        print ("*** There no adapter named {}. ***".format(adapter))

adapter_file.close()

# create trim path
if not os.path.exists(trim_path):
    os.mkdir(trim_path)
    print('The output result will be in "{}"'.format(trim_path))
else:
    print('The output result will be in "{}"'.format(trim_path))


# set the path
with open (map,'r') as mapping:
    print ("*** Loading mapping information ***")
    next(mapping)
    for line in mapping:
        sample,forward_fq,backward_fq = line.strip().split('\t')
        in_path = os.path.dirname(forward_fq)
        raw_path_sample_PE = forward_fq+' '+backward_fq
        raw_path = os.path.dirname(forward_fq)
        raw_path_fastqc = os.path.join(raw_path,'fastqc')
        if not os.path.exists(raw_path_fastqc):
            os.mkdir(raw_path_fastqc)

        trim_path_fastqc = os.path.join(trim_path,'fastqc')
        if not os.path.exists(trim_path_fastqc):
            os.mkdir(trim_path_fastqc)

        trim_path_sample = os.path.join(trim_path,sample)
        if not os.path.exists(trim_path_sample):
            os.mkdir(trim_path_sample)

        '''if trimlog:
            log_path ='-trimlog' +' '+ trim_path+'/'+sample+'.trim.log'
        else:
            log_path ='''''

        trim_r1 = os.path.join(trim_path_sample , (sample + '_R1.Trimmed.fq.gz'))
        trim_r2 = os.path.join(trim_path_sample , (sample + '_R2.Trimmed.fq.gz'))
        outtrim_r1 = os.path.join(trim_path_sample , (sample + '_R1.Outtrim.fq.gz'))
        outtrim_r2 = os.path.join(trim_path_sample , (sample + '_R2.Outtrim.fq.gz'))
        trim_path_sample_PE = trim_r1 +' '+ outtrim_r1 +' '+ trim_r2 +' '+ outtrim_r2
        print ("*** Working on sample {} ***".format(sample))
        command = '''
fastqc -t {threads} -o {raw_path_fastqc} {raw_path_sample_PE} -q && echo \"rawdata fastqc done!\"
trimmomatic PE -phred33 -threads {threads} {raw_path_sample_PE} \
    {trim_path_sample_PE} \
    ILLUMINACLIP:{adapter}:2:30:10 \
    SLIDINGWINDOW:5:20 LEADING:5 TRAILING:5 \
    MINLEN:50 && echo \"Rawdata trimmomatic done!\"
fastqc -t {threads} -o {trim_path_fastqc} {trim_path_sample_PE} -q && echo \"cleandata fastqc done!\"
        '''.format(threads=threads,raw_path_fastqc=raw_path_fastqc,raw_path_sample_PE=raw_path_sample_PE,trim_path_sample_PE=trim_path_sample_PE,trim_path_fastqc=trim_path_fastqc,adapter=adapter)
        os.system(command)

if rm_temp: os.system('rm -rf {}/*/*Outtrim*'.format(trim_path))
print ('*** temp files were deleted. ***')
mapping.close()
print ('*** {} is completed. ***'.format(os.path.basename(__file__)))

end = time.time()
print("*** Comsuming time:{}. ***".format(end-start))
