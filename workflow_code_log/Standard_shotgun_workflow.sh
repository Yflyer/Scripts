#conda install -c bioconda bbmap # bbmap is the bbtools
############################ run it before ##############################################
export PATH=$PATH/vd03/home/yufei/scripts
export DTB=$DTB/vd03/home/MetaDatabase
export SGENV=$SGENV/vd03/home/public_conda_envs/py36/share
export TRIMFA=$TRIMFA/vd02/yufei/shotgun_tutorial/TruSeq3-PE.fa
export RAWPATH=$RAWPATH/vd02/yufei/shotgun_tutorial/rawdata
#mkdir 00_rawdata
#cd 00_rawdata
#parallel -j 8 gzip -k -d ::: *.gz

#####################################
### need extra log command at each part

##################################################################
################### trimmomatic ######################
mkdir 01_cleandata
cd 01_cleandata
################### rename r1 ######################
ln -s $RAWPATH/r1/*gz ./
for i in *fastq.gz
do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  newname=${i/SRR197/L}
  mv ${i} ${newname/\.fastq\.gz/\_R1\.fq\.gz}
done
ln -s $RAWPATH/r2/*gz ./
for i in *fastq.gz
do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  newname=${i/SRR197/L}
  mv ${i} ${newname/\.fastq\.gz/\_R2\.fq\.gz}
done

## prepare adapters at first
ln -s $TRIMFA ./
parallel -j 10 --xapply 'trimmomatic PE -phred33 -threads 4 {1} {2} \
      trimmed.{1} outtrimmed.{1} trimmed.{2} outtrimmed.{2}  \
      ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
      SLIDINGWINDOW:5:20 LEADING:5 TRAILING:5 \
      MINLEN:50' ::: *_R1.fq.gz ::: *_R2.fq.gz
############### rm temp file and exit
rm outtrimmed.*
cd ..
################################

##################################################################
################### rm host ######################
##################################################################
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



##################################################################
################### contigs assembly ######################
##################################################################
############## megahit
mkdir -p 02_megahit
cd 02_megahit
################### rename r1 ######################
ln -s ../01_cleandata/trimmed*R1.fq.gz ./
for i in trimmed*R1.fq.gz
do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  newname=${i/trimmed\./}
  mv ${i} ${newname}
done
ln -s ../01_cleandata/trimmed*R2.fq.gz ./
for i in trimmed*R2.fq.gz
do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  newname=${i/trimmed\./}
  mv ${i} ${newname}
done
### prepare sample name list
ls -d *_R1.fq.gz | cut -d '_' -f1 > sample_list.txt
parallel -j 3 --xapply 'megahit -1 {1}_R1.fq.gz -2 {1}_R2.fq.gz --min-count 2 --k-list 29,39,51,67,85,107,133 -m 0.5 -t 16 --min-contig-len 500 --out-prefix {1} -o {1}' :::: sample_list.txt
#parallel -j 1 'megahit --12 {1} --min-count 2 --k-list 29,39,51,67,85,107,133 -m 0.5 -t 20 --min-contig-len 500 --out-prefix {.} -o {.}' ::: *.fastq
############ inter files rm
rm -rf */inter*

##########################################
################### ORF predict and annotation ######################
##################################################################
############## prokka
##
#.gff	This is the master annotation in GFF3 format, containing both sequences and annotations. It can be viewed directly in Artemis or IGV.
#.gbk	This is a standard Genbank file derived from the master .gff. If the input to prokka was a multi-FASTA, then this will be a multi-Genbank, with one record for each sequence.
#.fna	Nucleotide FASTA file of the input contig sequences.
#.faa	Protein FASTA file of the translated CDS sequences.
#.ffn	Nucleotide FASTA file of all the prediction transcripts (CDS, rRNA, tRNA, tmRNA, misc_RNA)
#.sqn	An ASN1 format "Sequin" file for submission to Genbank. It needs to be edited to set the correct taxonomy, authors, related publication etc.
#.fsa	Nucleotide FASTA file of the input contig sequences, used by "tbl2asn" to create the .sqn file. It is mostly the same as the .fna file, but with extra Sequin tags in the sequence description lines.
#.tbl	Feature Table file, used by "tbl2asn" to create the .sqn file.
#.err	Unacceptable annotations - the NCBI discrepancy report.
#.log	Contains all the output that Prokka produced during its run. This is a record of what settings you used, even if the --quiet option was enabled.
#.txt	Statistics relating to the annotated features found.
#.tsv	Tab-separated file of all features: locus_tag,ftype,len_bp,gene,EC_number,COG,product
############## megahit
mkdir -p 03_prokka
cd 03_prokka
################### rename r1 ######################
ln -s ../02_megahit/*/*.fa ./
ln -s ../02_megahit/sample_list.txt .
parallel -j 5 'prokka --addgenes --metagenome --outdir {} --prefix {} --mincontiglen 500 {}.contigs.fa' :::: sample_list.txt

############## interleaved fastq and adjust name
### merge cleandata
#ls ../01_cleandata/interleaved.trimmed.*-H0.R1.fastq | cut -d '-' -f1 | parallel -j 6 -k 'cat {}* > {/}.fastq'
#ls ../01_cleandata/interleaved.trimmed.*-H0.R1.fastq | cut -d '-' -f1 | parallel -j 1 'echo {}* {/}.fastq'
#parallel -j 20 --xapply 'reformat.sh -eoom -Xmx100g verifypaired=t in1={1} in2={2} out=interleaved.{1}' ::: *_R1.fastq ::: *_R2.fastq
#for i in interleaved.*
#do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
#  mv ${i} ${i/\_R1/}
#done

#for i in P*.fq; do echo ${i/\-[A-Z]*[^\.fq]/}; done


############# Usearch Workflow
usearch -fastx_findorfs reads.fastq -ntout -nt.fa -aaout aa.fa -orfstyle 7 -mincodons 16
usearch uniques
# use uparse but not cd hit
userach cluster
