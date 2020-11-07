#! /bin/bash
# this script is used for individually fastqc sample of shotgun
mkdir fastqc_result
for i in `ls *.gz`;
do
    fastqc -t 50 -o fastqc_result {raw_path_sample_PE} -q && echo \"rawdata fastqc done!\"
done

$test=''
for entry in `ls 9-V5_FDSW202415992-1r/*.gz`;
do
  x=${i}tt
done

for entry in "9-V5_FDSW202415992-1r"/*;
do
  x=$(echo "$entry")
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


for i in `ls *_30.fasta`;
do
    mv ${i} ../split_30/
done

for i in `ls`;
do
    mv ${i} ../split_30/
done
