### conda install psutil

./0_make_mapping.py 00_rawdata/ X 6
01_trim.py --input mapping.tsv --adapter TruSeq3-PE.fa --threads 80
02_megahit_assembly.py --input 01_cleandata --output 02_contigs_k21 -m 0.4 -t 80 --rmtemp True --kmin 21
02_megahit_assembly.py --input 01_cleandata --output 02_contigs_k81 -m 0.4 -t 80 --rmtemp True --kmin 81
02_spades_assembly.py --input 01_cleandata --output 02_contigs -t 80

# for test data
0_make_mapping.pylsl 00_rawdata/ S 10
01_trim.py --input mapping.tsv --adapter TruSeq2-PE.fa --threads 10

# for different kmer in megahit
02_megahit_assembly.py --input 01_cleandata --output 02_contigs_k41 -m 0.4 -t 8 --rmtemp True --kmin 41
02_megahit_assembly.py --input 01_cleandata --output 02_contigs_k81 -m 0.4 -t 8 --rmtemp True --kmin 81

# test for metaSpades
02_spades_assembly.py --input 01_cleandata --output 02_contigs -t 8

metaspades.py -o 02_contigs_spades -1 01_cleandata/SRR1976948/SRR1976948_R1.Trimmed.fq.gz -2 01_cleandata/SRR1976948/SRR1976948_R2.Trimmed.fq.gz -t 6 -m 16
