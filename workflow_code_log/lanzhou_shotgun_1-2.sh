conda install -c bioconda bbmap # bbmap is the bbtools
export PATH=$PATH:/vd03/home/yufei/scripts
export DTB=$DTB/vd03/home/MetaDatabase
export SGENV=$SGENV/vd03/home/public_conda_envs/py36/share

mkdir 00_rawdata
cd 00_rawdata
parallel -j 8 gzip -k -d ::: *.gz

mkdir 01_cleandata
cd 01_cleandata

ln -s ../00_rawdata/*fq ./

parallel -j 8 --xapply 'echo {1} {2}'  ::: *_R1.fq ::: *_R2.fq


############### trimmomatic and remove host reads
# 4 thread each job
parallel -j 8 --xapply 'kneaddata -i {1} -i {2} -o kneaddata_out -v \
 -db $DTB/Human_bowtie2 \
 --trimmomatic $SGENV/trimmomatic --trimmomatic-options "ILLUMINACLIP:TruSeq3-PE.fa:2:40:15 SLIDINGWINDOW:4:20 MINLEN:50" \
 -t 4 --bowtie2-options "--very-sensitive --dovetail" --remove-intermediate-output' \
  ::: *_R1.fq ::: *_R2.fq

# run parallel of each command:
# trimmomatic PE -phred33 -threads 4 {1} {2} trimmed.{1} trimmed.{2} ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50
# $SGENV/trimmomatic
parallel -j 10 --xapply 'trimmomatic PE -phred33 -threads 6 {1} {2} \
      trimmed.{1} outtrimmed.{1} trimmed.{2} outtrimmed.{2}  \
      ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
      SLIDINGWINDOW:5:20 LEADING:5 TRAILING:5 \
      MINLEN:50' ::: *_R1.fq ::: *_R2.fq

rm outtrimmed.*
#bowtie2 -p 8 -x GRCh38_noalt_as -1 SAMPLE_R1.fastq.gz -2 SAMPLE_R2.fastq.gz --un-conc-gz
## --reorder
#bowtie2 -p 8 -x $DTB/Human_bowtie2 -1 trimmed.29_R1.fq -2 trimmed.29_R2.fq -S test_mapped_and_unmapped.sam

parallel -j 10 --xapply 'reformat.sh verifypaired=t in1={1} in2={2} out=interleaved.{1}' ::: trimmed.*_R1.fastq ::: trimmed.*_R2.fastq

reformat.sh verifyinterleaved=t in1=trimmed.29_R1.fq in2=trimmed.29_R2.fq out=interleaved.trimmed.29.fastq

bowtie2 -p 8 -x $DTB/GRCh38_noalt_as/GRCh38_noalt_as --interleaved interleaved.trimmed.29.fastq --very-sensitive --dovetail -S interleaved.trimmed.29.sam
samtools view -bS interleaved.trimmed.29.sam > SAMPLE_mapped_and_unmapped.bam

parallel -j 10 --xapply 'kneaddata -i {1} -i {2} -o rm_host -v \
 -db ${DTB}/Human_bowtie2 \
 --bypass-trim  \
 -t 8 --bowtie2-options "--very-sensitive --dovetail" --remove-intermediate-output' \
  ::: trimmed.*_R1.fq ::: trimmed.*_R2.fq

rm *unmatch*
rm *bowtie2*
kneaddata_read_count_table --input rm_host --output kneaddata_sum.txt


### need to adjust name

parallel -j 10 --pipe --xapply 'trim-low-abund.py -V -Z 10 -C 3 -o - -M 32G --quiet --summary-info tsv {1} | extract-paired-reads.py -p pe.{1} -s se.{1}' ::: interleaved.*
parallel -j 10 --xapply 'trim-low-abund.py -V -Z 10 -C 3 -o ktrim.{1} -M 32G --quiet --summary-info tsv {1}' ::: interleaved.*
parallel -j 10 'extract-paired-reads.py -p pe.{} -s se.{}' ::: *fastq


parallel -j 10 'load-into-counting.py -T 8 -k 31 -q --summary-info -M 32G table.{1} {1}' ::: interleaved.*
filter-abund.py -T 8 -V -Z 10 -C -f 3 table.ct test.interleaved.fq

trim-low-abund.py -V -Z 10 -C 3 -o - -M 24G --quiet --summary-info tsv interleaved.trimmed.12_R1_kneaddata_paired_1.fastq | extract-paired-reads.py -p test_khmer_pe.fq.gz -s test_khmer_se.fq.gz
# need adjust name of input of megahit
for filename in ktrim*_R1_kneaddata_paired_1.fastq
do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  base=$(basename $filename _R1_kneaddata_paired_1.fastq)
  base=${base//ktrim.interleaved.trimmed./}
  mv ${filename} ${base}.fastq
done

mkdir -p 02_megahit
cd 02_megahit
ln -s ../01_cleandata/kmer.cut.*pe* ./
find . -name "*fastq" | parallel -j 4 echo {/.}
find . -name "*fastq" | parallel -j 4 megahit --12 {} --min-count 2 --k-list 29,39,51,67,85,107,133 -m 0.2 -t 20 --min-contig-len 200 --out-prefix {/.} -o {/.}

ln -s
parallel -j 4 'bowtie2-build {} {.}' ::: interleaved.*
bowtie2 -x test.idx -i test.interleaved.fq -b test.mapping.bam
bwa mem -p subset_assembly.fa $i > ${i}.aln.sam


# adjust pair name
for filename in *_R1_kneaddata_paired_1.fastq
do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  base=$(basename $filename _R1_kneaddata_paired_1.fastq)
  echo ${base}
  cat ${filename} | parallel -k --pipe 'sed -r "s/\#0\/1//g"' > ../${base}_paired_1.fastq
done

for filename in *_R1_kneaddata_paired_2.fastq
do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  base=$(basename $filename _R1_kneaddata_paired_2.fastq)
  echo ${base}
  cat ${filename} | parallel -k --pipe 'sed -r "s/\#0\/2//g"' > ../${base}_paired_2.fastq
done
#  sed -ri 's/\#0\/1//g' ${base}_R1_kneaddata_paired_1.fastq
#  sed -ri 's/\#0\/2//g' ${base}_R1_kneaddata_paired_2.fastq

for filename in ktrim*_R1_kneaddata_paired_1.fastq
do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  dir=$(dirname $filename)
  mv ${filename} ${dir}/${dir}.contigs.fa
done
