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
parallel -j 14 --xapply 'trimmomatic PE -phred33 -threads 4 {1} {2} \
      trimmed.{1} outtrimmed.{1} trimmed.{2} outtrimmed.{2}  \
      ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
      SLIDINGWINDOW:5:20 LEADING:5 TRAILING:5 \
      MINLEN:50' ::: *_R1.fq ::: *_R2.fq

bowtie2 -p 8 -x GRCh38_noalt_as -1 SAMPLE_R1.fastq.gz -2 SAMPLE_R2.fastq.gz --un-conc-gz
## --reorder
bowtie2 -p 8 -x $DTB/Human_bowtie2 -1 trimmed.29_R1.fq -2 trimmed.29_R2.fq -S test_mapped_and_unmapped.sam

parallel -j 3 --xapply 'kneaddata -i {1} -i {2} -o kneaddata_out -v \
 -db /mnt/f/database/Human_bowtie2 \
 --bypass-trim  \
 -t 4 --bowtie2-options "--very-sensitive --dovetail" --remove-intermediate-output' \
  ::: trimmed.*_R1.fq ::: trimmed.*_R2.fq

rm *unmatch*
rm *bowtie2*
kneaddata_read_count_table --input . --output kneaddata_sum.txt

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


### low kmer trim
parallel -j 3 --xapply 'interleave-reads.py {1} {2} -o merged.{1}' ::: *_paired_1.fastq ::: *_paired_2.fastq

parallel -j 3 --xapply 'trim-low-abund.py -V -Z 10 -C 2 -M 32G -o kmer.cut.{1} {1}' ::: merged*

### overlap merge
#bbmerge.sh in1=15_R1_kneaddata_paired_1.fastq in2=15_R1_kneaddata_paired_2.fastq out=test.fq outu1=unmerged1.fq outu2=unmerged2.fq

### parallel in kmer trimmed

trim-low-abund.py -V -Z 10 -C 2 -M 32G -o kmer.cut.{1} {1}
