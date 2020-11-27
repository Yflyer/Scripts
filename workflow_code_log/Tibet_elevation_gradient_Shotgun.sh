# trim and qc
# running time per sample 2216s (40min) for H01
# Contigs:megahit (80 cores)
# [21,29,39,59,79,99,119,141]
# 31 41 51 71 91 121
# k31: 6.5hours
# k41: 2 hours

# batch files sort
mv 01_b*/*_* 01_cleandata/
mv 02_b*/*_* 02_contigs_k21_megahit
rm -r 0*_b*

# batch1 b1
01_trim.py --input test1.txt --threads 100
02_megahit_assembly.py --input 01_cleandata --output 02_contigs_k21 -m 0.8 -t 100 --rmtemp True --kmin 31
# H1: k31-K41, 1 hr; k41-K51, 40 min; k111-k121, 10 min; total:12.8 hr for H0-H6

# batch1 b2: from b2, we set kmer-list 29,39,55,73,95,121 and min-kmer-count 2
01_trim.py --input test.txt --output 01_b2 --threads 120
02_megahit_assembly.py --input 01_b2 --output 02_b2 -m 0.8 -t 120 --rmtemp True
# V1: K29-K39, 48 min

# batch1 b3
# megahit allocate error due to insufficient memory
01_trim.py --input test.txt --output 01_b3 --threads 110 --rmtemp True
02_megahit_assembly.py --input 01_b3 --output 02_b3 -m 0.9 -t 110 --rmtemp True
#

# left
01_trim.py --input left.txt --threads 120

02_megahit_assembly.py --input 01_cleandata --output 02_contigs_k81 -m 0.4 -t 80 --rmtemp True --kmin 81
02_spades_assembly.py --input 01_cleandata --output 02_contigs -t 80

# for test data
#0_make_mapping.pylsl 00_rawdata/ S 10
01_trim.py --input mapping.tsv --adapter TruSeq2-PE.fa --threads 10

for i in 'ls raw_data/*/*_1.fq.gz';
do
cp $i raw_data
done
