# trim and qc
# running time per sample 2216s (40min) for H01
# Contigs:megahit (80 cores)
# [21,29,39,59,79,99,119,141]
# 31 41 51 71 91 121
# k31: 6.5hours
# k41: 2 hours

export PATH=$PATH/vd03/home/yufei/scripts
export DTB=$DTB/vd03/home/MetaDatabase
export SGENV=$SGENV/vd03/home/public_conda_envs/py36/share

mkdir 00_rawdata
cd 00_rawdata
parallel -j 20 gzip -k -d ::: *.gz


mkdir 01_cleandata
cd 01_cleandata

################### trimmomatic
ln -s ../00_rawdata/*fq ./
## prepare adapters at first
parallel -j 20 --xapply 'trimmomatic PE -phred33 -threads 4 {1} {2} \
      trimmed.{1.} outtrimmed.{1.} trimmed.{2.} outtrimmed.{2.}  \
      ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
      SLIDINGWINDOW:5:20 LEADING:5 TRAILING:5 \
      MINLEN:50' ::: *R1.fq.gz ::: *R2.fq.gz
############### inter files rm
rm outtrimmed.*
################################

##############  rm host
parallel -j 10 --xapply 'bowtie2 -p 8 -x $DTB/Human_bowtie2/hg37dec_v0.1 --very-sensitive --dovetail -1 {1} -2 {2} -S {1.}.sam' ::: trimmed.*_R1.fasq ::: trimmed.*_R2.fasq
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

################################ ktrim
parallel -j 2 --xapply -k 'trim-low-abund.py -V -Z 10 -C 3 -o - -M 128G --quiet --summary-info tsv {1} | extract-paired-reads.py -p pe.{1} -s se.{1} ' ::: interleaved.*
############# interfiles rm
rm se*
#################################


"/vd02/yufei/Tibet_shotgun/raw_data/r1/9-V1_FDSW202415988-1r_1.fq.gz"

############## interleaved fastq and adjust name
parallel -j 10 --xapply 'reformat.sh verifypaired=t in1={1.} in2={2.} out=interleaved.{1}.fastq' ::: trimmed.*_R1.fq ::: trimmed.*_R2.fq
for filename in interleaved.*.fastq
do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  base=${base//_R1/}
  mv ${filename} ${base}
done

######################### merge cleandata fastq
ls ../01_cleandata/interleaved.trimmed.*-H0.R1.fastq | cut -d '-' -f1 | parallel -j 6 -k 'cat {}* > {/}.fastq'


ln -s ../01_cleandata/pe* .
ln -s ../01_cleandata/interleave* .

############## megahit
mkdir -p 02_megahit
cd 02_megahit
find . -name "*fastq" | parallel -j 6 megahit --12 {} --min-count 2 --k-list 29,39,51,67,85,107,133 -m 0.2 -t 4 --min-contig-len 500 --out-prefix {/.} -o {/.}
############ inter files rm
rm */inter*

############## spades
parallel -j 2 'spades.py --meta --memory 160 --threads 20 --12 {} -o {.}' ::: *.fastq

######################### quast
quast.py -o report *.fa
#########################

######################### salmon mapping
######### optional
######################### merge contigs (for contig mergging)
ln -s  ../02_megahit/*/interleaved.trimmed.*.fa .
ls interleaved.trimmed.*-H0*.fa | cut -d '-' -f1 | parallel -j 6 -k 'cat {}* > {}.contigs.fa'
parallel -j 6 'salmon index -t {} -i {.}.sal-idx' ::: *fa
parallel -j 6 --xapply 'salmon quant -i {1} --libType IU -1 {2} -2 {3} -o {1.}.quant' :::: idx.txt :::: r1.txt :::: r2.txt
##########################

ln -s ../01 /*/*.fa
ls *fa | cut -d '.' -f3 | parallel -j 3 'echo {}'
ls *fa | cut -d '.' -f3 | parallel -j 3 'salmon index -t interleaved.trimmed.{}.contigs.fa -i {}.sal-idx'

####### salmon split
ls *.fastq | parallel -j 18 -k split-paired-reads.py {} -1 R1.{} -2 R2.{}

######## salmon quant
ls -d *idx > idx.txt
ls -d R1*.fastq>r1.txt
ls -d R2*.fastq>r2.txt
parallel -j 3 --xapply 'echo {1} {2} {3}' :::: idx.txt :::: r1.txt :::: r2.txt
parallel -j 3 --xapply 'salmon quant -i {1} --libType IU -1 {2} -2 {3} -o {1.}.quant' :::: idx.txt :::: r1.txt :::: r2.txt
### :::: 代表文件
### su root to use： strac -p pid # to trace the process whether stuck

######## run_MaxBin
### abund list generation
ls *fa | cut -d '.' -f3 | parallel -j 3 "awk '/k133/{print $1,$4}' ../03_megahit_mapping/{}.quant/quant.sf > abund.{}.tsv"
######### for loop
for i in *fa
do
  base=$(basename $i .contigs.fa)
  base=${base/interleaved.trimmed.}
  awk '/k133/{print $1,$4}' ../03_merge_megahit_mapping/${base}.quant/quant.sf > ${base}.abund.tsv
done

###################### run_MaxBin
####### mkdir work dir
ls *.tsv | cut -d '.' -f1 | parallel mkdir {}
############ parallel
ls *.tsv | cut -d '.' -f1 | parallel -j 6 'echo interleaved.trimmed.{}.contigs.fa {}/{} {}.abund.tsv'
ls *.tsv | cut -d '.' -f1 | parallel -j 6 'run_MaxBin.pl -thread 30 -contig interleaved.trimmed.{}.contigs.fa -out {} -abund {}.abund.tsv'
####### for loop kind
for i in *.tsv
do
  run_MaxBin.pl -thread 30 -contig interleaved.trimmed.${i/.abund.tsv/}.contigs.fa -out ${i/.abund.tsv/}/${i/.abund.tsv/} -abund ${i/.abund.tsv/}.abund.tsv
done




##### 04 annotation
parallel -j 9 'prokka --addgenes --metagenome --outdir {.} --prefix {.} --mincontiglen 500 {}' ::: *.fa

### Prokka needs blastp 2.2 or higher. Please upgrade and try again.
