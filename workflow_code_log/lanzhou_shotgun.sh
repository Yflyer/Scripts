# this is code log of lanzhou data
# data clean
# 1
# trim and remove host
01_trim.py --input test.txt --threads 10 --rmtemp True

mkdir 01_clean_data
cd 01_clean_data
ln -s ../raw_data/H*/* ./

find . -name "*R1*" | cut -d '_' -f1 | parallel -j12 kneaddata -i {}_R1.fq.gz -i {}_R2.fq.gz \
-o . -v -t 8 --remove-intermediate-output \
--trimmomatic $P36/trimmomatic \
--bowtie2 /vd03/home/public_conda_envs/py36/bin/
--bowtie2-options --dovetail\
-db $DTB/Human_bowtie2 \

parallel -j 12 --xapply 'kneaddata -i {1} -i {2} -o kneaddata_out -v \
-db $DTB/Human_bowtie2  \
--trimmomatic $P36/trimmomatic/ --trimmomatic-options "SLIDINGWINDOW:4:20 MINLEN:50" \
-t 6 --bowtie2-options "--very-sensitive --dovetail" --remove-intermediate-output' \
 ::: raw_data/*_R1.fastq ::: raw_data/*_R2.fastq

rm *unmatch*
rm *bowtie2*

kneaddata_read_count_table --input 01_rmhost --output kneaddata_sum.txt

# adjust pair name
for filename in *_R1_kneaddata_paired_1.fastq
do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  base=$(basename $filename _R1_kneaddata_paired_1.fastq)
  echo $base

  sed -ri 's/\#0\/1//g' ${base}_R1_kneaddata_paired_1.fastq
  sed -ri 's/\#0\/2//g' ${base}_R1_kneaddata_paired_2.fastq
done

mkdir -p 01_kmer_trim
cd 01_kmer_trim
ln -s ../01_rmhost/*paired* ./

for filename in *_R1.Trimmed_kneaddata_paired_1.fastq
do
  #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  base=$(basename $filename _R1.Trimmed_kneaddata_paired_1.fastq)
  echo $base

  interleave-reads.py ${base}_R1.Trimmed_kneaddata_paired_1.fastq ${base}_R1.Trimmed_kneaddata_paired_2.fastq | \
  trim-low-abund.py - -V -Z 10 -C 3 -o - --gzip -M 8e9 | \
  extract-paired-reads.py --gzip -p ${base}_khmer_pe.fq.gz -s ${base}_khmer_se.fq.gz
done

mkdir -p 03_mapping
cd 03_mapping
ln -s ../02_contigs_k21_megahit/*/*.contigs.fa .

bwa index 1_H0.contigs.fa #8 min

mkdir -p 04_bin
cd 04_bin
ln -s ../01_rmhost/*paired* ./

run_MaxBin.pl ../02_contigs_k21_megahit/1_H0/1_H0.contigs.fa
run_MaxBin.pl -contig ../02_contigs_k21_megahit/1_H0/1_H0.contigs.fa -out 1_H0_maxbin -thread 80


'''
for filename in *_R1.Trimmed_kneaddata_paired_1.fastq
do
  #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  base=$(basename $filename _R1.Trimmed_kneaddata_paired_1.fastq)
  echo $base

  interleave-reads.py ${base}_R1.Trimmed_kneaddata_paired_1.fastq ${base}_R1.Trimmed_kneaddata_paired_2.fastq | \
  trim-low-abund.py - -V -Z 10 -C 3 -o - --gzip -M 8e9 | \
  extract-paired-reads.py --gzip -p ${base}_khmer_pe.fq.gz -s ${base}_khmer_se.fq.gz
done
'''
