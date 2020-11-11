# this is code log of lanzhou data
# data clean
# 1
# trim and remove host
01_trim.py --input test.txt --threads 10 --rmtemp True

mkdir 01_rmhost
cd 01_rmhost
ln -s ../01_cleandata/H*/*Trimmed* ./

for filename in *_R1.Trimmed.fq.gz
do
  #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  base=$(basename $filename _R1.Trimmed.fq.gz)
  echo $base

  kneaddata -i ${base}_R1.Trimmed.fq.gz -i  ${base}_R2.Trimmed.fq.gz \
  -o . -v -t 10 --remove-intermediate-output \
  --bypass-trim \
  --bowtie2-options '--very-sensitive --dovetail' \
  --bowtie2-options="--reorder" \
  -db $DTB/Homo_sapiens
done

rm *_R1.Trimmed.fq.gz
ln -s H*/*fastq ./
rm *unmatch*
rm *bowtie2*

cd ..


kneaddata_read_count_table --input 01_rmhost --output kneaddata_sum.txt


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