############# OK warming 16s #####################
############# workflow code ######################
######### Yufei Zeng, zengyf93@qq.com ############
# the rawdata from OU have some problems in suiting QIIME2. I have to write some specific scripts to clean these data. You can skip it to look at part 2 or part 3. If you have interest about these scripts, please contact me.
####### 1. split, clean and cut primers ###########################################
####### runing environment: python3
split_by_tag.py merge_merge_18S_R1_run1_run2andrun3_and2016_WandC.fastq 00_rawdata/r1 --
split_by_tag.py merge_merge_18S_R2_run1_run2andrun3_and2016_WandC.fastq 00_rawdata/r2 --
split_by_tag.py merge_R1_2015and16_80sample18S_final.fastq 00_rawdata/r1 --
split_by_tag.py merge_R2_2015and16_80sample18S_final.fastq 00_rawdata/r2 --

mkdir -p 01_cleandata
mkdir -p 01_cleandata/r1
mkdir -p 01_cleandata/r2
pair_check_by_files.py --r1 00_rawdata/r1 --r2 00_rawdata/r2 --output 01_cleandata

# r1 and r2 cut primers
# this step also can be done in qiime2. however, too slow.
# report file can be used to check detailed information of each sample
# X11_24N_N_C_0.fastqS.fq
# X15_19N.fastq

cd 01_cleandata/r1
for i in `ls *.fastq`;
do
    cutadapt -g CCAGCASCYGCGGTAATTCC -o ptrim_${i} -m 150 -M 350 --trimmed-only --max-n 0 -j 8 ${i} > ../../ptrim_r1_report_txt
    rm ${i}
done

cd ../r2
for i in `ls *.fastq`;
do
    cutadapt -g ACTTTCGTTCTTGATYRA -o ptrim_${i} -m 150 -M 350 --trimmed-only --max-n 0 -j 8 ${i} > ../../ptrim_r2_report_txt
    #rm ${i}
done

cd ../..

# check again
mkdir -p 02_ptrim
mkdir -p 02_ptrim/r1
mkdir -p 02_ptrim/r2
pair_check_by_files.py --r1 01_cleandata/r1 --r2 01_cleandata/r2 --output 02_ptrim

#### generate mapping for importing
make_mapping_qiime2.py 02_ptrim/r1 02_ptrim/r2

####### 2. QIIME2 workflow #################################################################
####### 2.1 import
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path mapping.tsv --output-path demux.qza --input-format PairedEndFastqManifestPhred33V2
qiime demux summarize --i-data demux.qza --o-visualization demux.qzv
# the quality control (qc) result is imported to the result folder.
qiime tools export  --input-path demux.qzv --output-path result/1_seq-qc

####### 2.2 dada2
### the setting of parameters are selected by the result of part 3 (see the files of 'parameters_selection' in result foilder).
# To decrease chimeric rate, chemeric parent-over-abundance was set.

qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 250 --p-trunc-len-r 234 --p-min-fold-parent-over-abundance 8 --p-n-threads 8 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2
done
biom convert -i result/2-dada2/feature-table.biom -o result/2-dada2/feature-table.tsv --to-tsv

#### TREE
qiime alignment mafft --i-sequences dada2-rep-seqs.qza --o-alignment aligned-rep-seqs.qza
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree fasttree-tree.qza
qiime phylogeny midpoint-root --i-tree fasttree-tree.qza --o-rooted-tree rooted-fasttree-tree.qza

#### TAXA
qiime feature-classifier classify-sklearn --i-classifier  $DTB/pr2_protists/trim-pr2-18S_classifier.qza --i-reads dada2-rep-seqs.qza  --o-classification taxonomy.qza
qiime tools export  --input-path taxonomy.qza --output-path result/3_classification
qiime tools export --input-path rooted-fasttree-tree.qza --output-path result/4_tree/fasttree
qiime tools export --input-path aligned-rep-seqs.qza --output-path result/4_tree

qiime feature-classifier classify-sklearn --i-classifier  $DTB/silva_18s_classifier/trim_99_18S_silva_classifier.qza --i-reads dada2-rep-seqs.qza  --o-classification silva.taxonomy.qza
qiime tools export  --input-path silva.taxonomy.qza --output-path result/3_classification

### VSEARCH
# joined paired
# _R1 need
ln -s ../../02_ptrim/r1/ptrim_X* .
for i in *.fastq;
do
sample=$(basename ${i} .fastq);
mv $i ${sample#*_}_R1.fq;
done

ln -s ../../02_ptrim/r2/ptrim_X* .
for i in *.fastq;
do
sample=$(basename ${i} .fastq);
mv $i ${sample#*_}_R2.fq;
done

for i in *.fq;
do
mv $i ${i/_/P};
done

# .fq merge
usearch -threads 80 -fastq_mergepairs *R1*.fq -relabel @ -fastq_maxdiffs 10 \
  -fastq_pctid 80 -fastqout merged.fq

#length trim
cd ..
usearch -fastx_truncate rawdata/merged.fq -trunclen 250 -fastqout reads250.fq
# qc
usearch -threads 80 -fastq_filter reads250.fq -fastq_maxee 1.0 -fastaout filtered.fa

# Find unique read sequences and abundances
usearch -threads 80 -fastx_uniques filtered.fa -sizeout -relabel Uniq -fastaout uniques.fa

# Make 97% OTUs and filter chimeras
usearch -threads 80 -cluster_otus uniques.fa -otus otus.fa -relabel Otu -threads 80

# map otu reads to seq to get otu counts table
usearch -threads 80 -otutab filtered.fa -otus otus.fa -otutabout otutab.txt -mapout map.txt

# annotate
qiime tools import --type 'FeatureData[Sequence]' --input-path otus.fa --output-path otus.qza
qiime feature-classifier classify-sklearn --p-n-jobs 80 --i-classifier $DTB/silva_18s_classifier/trim_99_18S_silva_classifier.qza --i-reads otus.qza  --o-classification taxonomy.qza
qiime tools export  --input-path taxonomy.qza --output-path otu_annotat_result/

# Denoise: predict biological sequences and filter chimeras
usearch -threads 80 -unoise3 uniques.fa -zotus zotus.fa -threads 80
usearch -threads 80 -otutab filtered.fa -zotus zotus.fa -otutabout zotutab.txt -mapout zmap.txt


INPUT='someletters_12345_moreleters.ext'
SUBSTRING=$(echo $INPUT| cut -d'_' -f 2)

tmp=${a#*_}   # remove prefix ending in "_"
b=${tmp%_*}   # remove suffix starting with "_"



# CHIMERA CHECKING
qiime vsearch uchime-denovo \
  --i-table atacama-table.qza \
  --i-sequences atacama-rep-seqs.qza \
  --output-dir uchime-dn-out
qiime feature-table filter-features \
  --i-table atacama-table.qza \
  --m-metadata-file uchime-dn-out/nonchimeras.qza \
  --o-filtered-table uchime-dn-out/table-nonchimeric-wo-borderline.qza
qiime feature-table filter-seqs \
  --i-data atacama-rep-seqs.qza \
  --m-metadata-file uchime-dn-out/nonchimeras.qza \
  --o-filtered-data uchime-dn-out/rep-seqs-nonchimeric-wo-borderline.qza
qiime feature-table summarize \
  --i-table uchime-dn-out/table-nonchimeric-wo-borderline.qza \
  --o-visualization uchime-dn-out/table-nonchimeric-wo-borderline.qzv

qiime vsearch dereplicate-sequences \
  --i-sequences demux.qza \
  --o-dereplicated-table OTU-table.qza \
  --o-dereplicated-sequences OTU-rep-seqs.qza

qiime vsearch cluster-features-de-novo \
  --i-table OTU-table.qza \
  --i-sequences OTU-rep-seqs.qza \
  --p-perc-identity 0.97 \
  --o-clustered-table OTU-table-97.qza \
  --o-clustered-sequences OTU-rep-seqs-97.qza
