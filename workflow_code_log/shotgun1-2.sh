conda install -c bioconda bbmap # bbmap is the bbtools
export PATH=$PATH/vd03/home/yufei/scripts
export DTB=$DTB/vd03/home/MetaDatabase
export SGENV=$SGENV/vd03/home/public_conda_envs/py36/share

mkdir 00_rawdata
cd 00_rawdata
parallel -j 8 gzip -k -d ::: *.gz


mkdir 01_cleandata
cd 01_cleandata

################### trimmomatic
ln -s ../00_rawdata/*fq ./
## prepare adapters at first
parallel -j 10 --xapply 'trimmomatic PE -phred33 -threads 16 {1} {2} \
      trimmed.{1.}.fastq outtrimmed.{1.}.fastq trimmed.{2.}.fastq outtrimmed.{2.}.fastq  \
      ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
      SLIDINGWINDOW:5:20 LEADING:5 TRAILING:5 \
      MINLEN:50' ::: *_R1.fq ::: *_R2.fq
############### inter files rm
rm outtrimmed.*
################################

##############  rm host
parallel -j 10 --xapply 'bowtie2 -p 8 -x $DTB/Human_bowtie2/hg37dec_v0.1 --very-sensitive --dovetail -1 {1} -2 {2} -S {1.}.sam' ::: trimmed.*_R1.fq.fastq ::: trimmed.*_R2.fq.fastq
parallel -j 10 --xapply -k 'samtools view -@ 8 -bS {1} > {1.}.bam' ::: *.sam
# bump: both unmapped pair
parallel -j 10 --xapply -k 'samtools view -b -@ 8 -f 12 -F 256 {1} > bump.{1}' ::: *.bam
parallel -j 10 --xapply -k 'samtools sort -n -m 6G -@ 8 {1} -o sorted.{1}' ::: bump.*.bam
parallel -j 10 --xapply -k 'samtools fastq -@ 8 {1} \
    -1 {1.}_R1.fastq \
    -2 {1.}_R2.fastq -n ' ::: sorted.*.bam
############### inter files rm
rm *bam
rm *sam
################################
cd ..

### merge cleandata
ls ../01_cleandata/interleaved.trimmed.*-H0.R1.fastq | cut -d '-' -f1 | parallel -j 6 -k 'cat {}* > {/}.fastq'
ls ../01_cleandata/interleaved.trimmed.*-H0.R1.fastq | cut -d '-' -f1 | parallel -j 1 'echo {}* {/}.fastq'

############## megahit
mkdir -p 02_megahit
cd 02_megahit
ln -s ../01_clean_data_2/sorted.*fastq ./

############ inter files rm
rm */inter*

############## interleaved fastq and adjust name
parallel -j 20 --xapply 'reformat.sh -eoom -Xmx100g verifypaired=t in1={1} in2={2} out=interleaved.{1}' ::: *_R1.fastq ::: *_R2.fastq
for i in interleaved.*
do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  mv ${i} ${i/\_R1/}
done

for i in P*.fq; do echo ${i/\-[A-Z]*[^\.fq]/}; done
############## megahit
mkdir -p 02_megahit
cd 02_megahit
parallel -j 1 'megahit --12 {1} --min-count 2 --k-list 29,39,51,67,85,107,133 -m 0.5 -t 20 --min-contig-len 200 --out-prefix {.} -o {.}' ::: *.fastq
############ inter files rm
rm */inter*

| cut -d '_' -f1 |
