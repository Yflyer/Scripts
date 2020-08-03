#! /bin/bash
# this script is used for individually fastqc sample of shotgun

for i in `ls *.gz`;
do
    fastqc ${i}
done

base=$(basename $filename _1.fastq.gz)

#### r1 cutadapt
for i in `ls *.fastq`;
do
    cutadapt -g GTGCCAGCMGCCGCGGTAA -o ptrim_${i} -j6 ${i}
done

#### r2 cutadapt
for i in `ls *.fastq`;
do
    cutadapt -g GGACTACHVGGGTWTCTAAT -o ptrim_${i} -j6 ${i}
done
