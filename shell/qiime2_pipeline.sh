# This is a pipeline of QIIME2 command for THU UG.
# Please run in activated conda QIIME2 environment
# Yufei, 5/15/2020, zengyf@qq.com

############## demultiplexing #################
### NOTE: if you used data from IEG, used extra perl script to demultiplexing when you have rawdata include: R1.fastq, R2.fastq, index.fastq, barcode_list.txt.
### replace by your exact file name in following command
Split_libraries_fastq.pl --f1 R1.fastq --f2 R2.fastq --map barcode_list.txt --index index.fastq --o1 demux_R1.fq --o2 demux_R2.fq

############## optional #################
### sometimes sample name are long and complex, hardly understood. use RE pattern '[previous name]/[target part of string]/[change to this part]' like following
for i in *fastq.gz
do #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  mv ${i} ${i/[target part of string]/[change to this part]}
done

############### create mapping file for python ##################
### NOTE: move the r1.fastq r2.fastq to file directory "r1" "r2"
### NOTE please make sure that your fastq file in r1 and r2 are look like [samplename]_R1.fastq and [samplename]_R2.fastq
# mapping seq files
make_mapping_qiime2.py r1 r2

# optional: check
# NOTE: if you used check script, should re-generate mapping file.
pair_check.py --input mapping.tsv
fastq_check.py --input r1 --output check_r1
fastq_check.py --input r2 --output check_r2

###############################################################################
############## qiime2 workflow ###############################################
# In this step, we use plugin: demux, https://docs.qiime2.org/2020.2/plugins/available/demux/
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path mapping.tsv --output-path demux.qza --input-format PairedEndFastqManifestPhred33V2
qiime demux summarize --i-data demux.qza --o-visualization demux.qzv
qiime tools export  --input-path demux.qzv --output-path result/0_seq-qc

# cut the primers;
# In this step, we use plugin: cutadapt (trim-paired),https://docs.qiime2.org/2020.2/plugins/available/cutadapt/
# in this example, we used 515-806
##### note: if you have trimed primers, please skip this step and change input name in the DADA2. ###########################
qiime cutadapt trim-paired --i-demultiplexed-sequences demux.qza --p-front-f GTGCCAGCMGCCGCGGTAA --p-front-r CCGTCAATTCMTTTRAGTTT --p-minimum-length 200 --o-trimmed-sequences trim-demux.qza --p-discard-untrimmed true
qiime demux summarize --i-data trim-demux.qza --o-visualization trim-demux.qzv
qiime tools export  --input-path trim-demux.qzv --output-path result/1_trim-seq-qc

##### Dada2
# set the parameters by qc-result
qiime dada2 denoise-paired --i-demultiplexed-seqs trim-demux.qza --p-trunc-len-f 220 --p-trunc-len-r 195 --p-n-threads 32 --o-table dada2-table.qza --p-min-fold-parent-over-abundance 8 --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2-1
done


# cut more to imporve percentage
qiime dada2 denoise-paired --i-demultiplexed-seqs trim-demux.qza --p-trunc-len-f 200 --p-trunc-len-r 200 --p-trim-left-f 10 --p-trim-left-r 10 --p-n-threads 4 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2-2
done

# chimera setting
# chimera: there are a real seq X and a real seq Y. If Z = (part of X) + (part of Y) during PCR, Z is a chimera.
qiime dada2 denoise-paired --i-demultiplexed-seqs trim-demux.qza --p-trunc-len-f 200 --p-trunc-len-r 200 --p-trim-left-f 10 --p-trim-left-r 10 --p-n-threads 4  --o-table dada2-table.qza --p-min-fold-parent-over-abundance 8 --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2-3
done

# optional: visualization of feature tabulate
qiime feature-table summarize --i-table dada2-table.qza --o-visualization dada2-table.qzv

# optional: change biom to csv
biom convert -i result/2-dada2/feature-table.biom -o result/2-dada2/feature-table.tsv --to-tsv

##### classification
### if you have trained a classifier, please run：
qiime feature-classifier classify-sklearn --p-n-jobs 4 --i-classifier  99_16S_silva_F515_R806_classifier.qza --i-reads dada2-rep-seqs.qza --o-classification taxonomy.qza
qiime tools export  --input-path taxonomy.qza --output-path result/3_classification
### if not, please run following command and then come back

# create the folder for classifier
mkdir /vd02/home3/test_data/training_classifiers
cd training_classifiers

# import ref seq and taxonomy
qiime tools import --type 'FeatureData[Sequence]' --input-path /vd02/home3/test_data/silva_132_99_16S.fna --output-path 99_16S_silva_ref_seq.qza

qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path /vd02/home3/test_data/16S_majority_taxonomy_7_levels.txt --output-path 99_16S_silva_ref_taxonomy.qza

# we extract reads on F515 to R806 to imporve accuracy
qiime feature-classifier extract-reads --i-sequences 99_16S_silva_ref_seq.qza --p-f-primer GTGYCAGCMGCCGCGGTAA --p-r-primer GGACTACNVGGGTWTCTAAT --p-min-length 200 --p-max-length 290 --o-reads trim_99_16S_silva_ref_seq.qza

qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads trim_99_16S_silva_ref_seq.qza --i-reference-taxonomy 99_16S_silva_ref_taxonomy.qza --o-classifier 99_16S_silva_F515_R806_classifier.qza

##### phylogenetic tree
# mafft to align seqs
qiime alignment mafft --i-sequences dada2-rep-seqs.qza --o-alignment aligned-rep-seqs.qza

# mask
# why mask: avoid the effect of low-complexity sequences to alignment algorithms
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza

# FASTTREE to built a tree
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree fasttree-tree.qza

# Root the tree: make the distance comparable.
qiime phylogeny midpoint-root --i-tree fasttree-tree.qza --o-rooted-tree rooted-fasttree-tree.qza

# export the tree and aligned seqs
qiime tools export --input-path rooted-fasttree-tree.qza --output-path result/4_tree/fasttree
qiime tools export --input-path aligned-rep-seqs.qza --output-path result/4_tree

##### Till now, we genrate four result of QIIME2. Actually it can do more, you can explore it by your interest
##### in this tutorial, we hope:
# know how to qiime --help
# know qiime tools export/import
# know how to set Dada2
# know how to classify otu
# know how to align and bulit a tree
