./0_make_mapping.py 00_rawdata/ X 6
./01_trim.py mapping.tsv TruSeq3-PE.fa 80 | tee 01_trim.log.txt
./02_assembly.py -i 01_cleandata -o 02_contigs_k81 -m 0.4 -t 80 -r --kmin 61 | tee 02_assembly.log.txt

###### for test data in my pc
0_make_mapping.py 00_rawdata/ X 6
01_trim.py --input mapping.tsv --adapter TruSeq2-PE.fa --threads 6
02_assembly.py -i 01_cleandata -o 02_contigs -m 0.4 -t 6 -r -kmin 41
