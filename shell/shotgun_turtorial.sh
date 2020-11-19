### rename the list
for file in *.fastq.gz; do mv -- "$file" "${file%.fastq*}_R1.fastq.gz"; done
for file in *.fastq.gz; do mv -- "$file" "${file%.fastq}_R1.fastq.gz"; done


01_trim.py --input test.txt --threads 10 --rmtemp True

mkdir 01_rmhost
cd 01_rmhost
ln -s ../00_rawdata/*.fastq.gz ./

for filename in *_R1.fastq.gz
do
  #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  base=$(basename $filename _R1.fastq.gz)
  echo $base

  kneaddata -i ${base}_R1.fastq.gz -i ${base}_R2.fastq.gz \
  -o . -v -t 8 --remove-intermediate-output \
  --trimmomatic ~/anaconda3/envs/py35/share/trimmomatic \
   --trimmomatic-options 'ILLUMINACLIP:~/anaconda3/envs/py35/share/trimmomatic/adapters/TruSeq3-PE.fa:2:40:15 SLIDINGWINDOW:4:20 MINLEN:50' \
  --bowtie2-options '--very-sensitive --dovetail' \
  --bowtie2-options="--reorder" \
  -db $DTB/Homo_sapiens
done

rm *unmatch*
rm *bowtie2*

for file in *paired_*.fastq*; do mv -- "$file" "${file%_R2_}"; done

cd ..
kneaddata_read_count_table --input 01_rmhost --output kneaddata_sum.txt

### rm low-kmers
mkdir -p 01_kmer_trim
cd 01_kmer_trim
ln -s ../01_rmhost/*paired* ./

for filename in *_R1_kneaddata_paired_1.fastq
do
  #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  base=$(basename $filename _R1_kneaddata_paired_1.fastq)
  echo $base

  interleave-reads.py ${base}_R1_kneaddata_paired_1.fastq ${base}_R1_kneaddata_paired_2.fastq | \
  trim-low-abund.py - -V -Z 10 -C 3 -o - --gzip -M 8e9 | \
  extract-paired-reads.py --gzip -p ${base}_khmer_pe.fq.gz -s ${base}_khmer_se.fq.gz
done

find . -name "*R1*fastq" | cut -d '_' -f1 | parallel -j6 interleave-reads.py {}_R1_kneaddata_paired_1.fastq ${}_R1_kneaddata_paired_2.fastq | \
trim-low-abund.py - -V -Z 10 -C 3 -o - --gzip -M 8e9 | \
extract-paired-reads.py --gzip -p {}_khmer_pe.fq.gz -s {}_khmer_se.fq.gz


### megahit
mkdir -p 02_contigs_megahit
cd 02_contigs_megahit
ln -s ../01_kmer_trim/H*pe* ./

for filename in H*pe*;
do
base=$(basename $filename _khmer_pe.fq.gz) ;
megahit --12 $filename --k-list 29,39,55,73,95,121 -m 0.9 -t 110 -o $base  ;
done

mkdir -p 02_parallel_test
cd 02_parallel_test
ln -s ../01_kmer_trim/H*pe* ./
find . -name "H*pe*" | parallel  megahit --12 {} --k-list 21,29,39,55,73,95,121 -m 0.2 -t 8 -o {.}
