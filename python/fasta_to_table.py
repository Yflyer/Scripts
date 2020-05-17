#!/usr/bin/env python
# -*- coding:utf-8 -*-
# transfer the fasta (mostly as repseq) to table which may be good for downstream
import sys

with open (sys.argv[1],'r') as file:
    #f = file.readlines()
    repseq = open (sys.argv[2],'w')
    for line in file:
        repseq.write(line.strip('>').strip()+'\t'+next(file))
