############# OK warming 16s #####################
############# workflow code ######################
######### Yufei Zeng, zengyf93@qq.com ############
# the rawdata from OU have some problems in suiting QIIME2. I have to write some specific scripts to clean these data. You can skip it to look at part 2 or part 3. If you have interest about these scripts, please contact me.
####### 1. split, clean and cut primers ###########################################
####### runing environment: python3
split_by_tag.py 16s_rawdata/merge_R1_2015and16_80sample16S_final.fastq 00_rawdata/r1 --
split_by_tag.py 16s_rawdata/merge_R2_2015and16_80sample16S_final.fastq 00_rawdata/r2 --
split_by_tag.py 16s_rawdata/16S_2015and16_WandC_finalmerge_R1.fastq 00_rawdata/r1 --
split_by_tag.py 16s_rawdata/16S_2015and16_WandC_finalmerge_R2.fastq 00_rawdata/r2 --
split_by_tag.py 16s_rawdata/merge_16S_264sample_15and16WandC_final_R1.fastq 00_rawdata/r1 --
split_by_tag.py 16s_rawdata/merge_16S_264sample_15and16WandC_final_R2.fastq 00_rawdata/r2 --

pair_check_by_files.py --r1 00_rawdata/r1 --r2 00_rawdata/r2 --output 01_cleandata

# r1 and r2 cut primers
# this step also can be done in qiime2. however, too slow.
# report file can be used to check detailed information of each sample
cd 01_cleandata/r1
for i in `ls *.fastq`;
do
    cutadapt -g GTGCCAGCMGCCGCGGTAA -o ptrim_${i} -m 200 -M 270 --trimmed-only --max-n 0 -j 6 ${i} >> ../../ptrim_r1_report_txt
    rm ${i}
done

cd ../r2
for i in `ls *.fastq`;
do
    cutadapt -g GGACTACHVGGGTWTCTAAT -o ptrim_${i} -m 200 -M 270 --trimmed-only --max-n 0 -j 6 ${i} >> ../../ptrim_r2_report_txt
    rm ${i}
done

cd ../..

# check again
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

qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 220 --p-trunc-len-r 160 --p-min-fold-parent-over-abundance 8 --p-n-threads 8 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2-4
done
biom convert -i result/2-dada2/feature-table.biom -o result/2-dada2/feature-table.tsv --to-tsv


qiime alignment mafft --i-sequences dada2-rep-seqs.qza --o-alignment aligned-rep-seqs.qza
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree fasttree-tree.qza
qiime phylogeny midpoint-root --i-tree fasttree-tree.qza --o-rooted-tree rooted-fasttree-tree.qza
qiime feature-classifier classify-sklearn --i-classifier  $DTB/silva_16s_classifier/99_16S_silva_F515_R806_classifier.qza --i-reads dada2-rep-seqs.qza  --o-classification taxonomy.qza
qiime tools export  --input-path taxonomy.qza --output-path result/3_classification
qiime tools export --input-path rooted-fasttree-tree.qza --output-path result/4_tree/fasttree
qiime tools export --input-path aligned-rep-seqs.qza --output-path result/4_tree

####### 3. Other information #################################################################
# Multiply tests are aranged to get potentially best parameters in a 11-samples pre-analysis.

# Acording to qc result, turncate at 224th base of left end for both forward and backward.
# although this setting has the largest overlap, the merge percentages are not good, especially from the samples during 15-16 year.
qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 224 --p-trunc-len-r 224 --p-n-threads 8 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2-1
done

# turncate more at left end to get better quality at reverse sequence.
# the merge percentages of 15-16 year sample are better.
qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 224 --p-trunc-len-r 180 --p-n-threads 8 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2
done

# turncate more at both ends to get better quality at reverse sequence.
# however, the merge percentages of other samples become lower.
qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 210 --p-trunc-len-r 160 --p-n-threads 8 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2-3
done

# extend the forward length to increase overlap and get good qc of backward.
# result: not good.
qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 220 --p-trunc-len-r 160 --p-n-threads 8 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2-4
done

# extend the forward length to increase overlap and make sure good qc of backward.
# cut a little at right end to check whether primers remain. (primers will greatly lower the effect of dada2)
# result: not good.
qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 220 --p-trunc-len-r 160 --p-trim-left-f 3 --p-trim-left-r 3 --p-n-threads 8 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2-5
done

# try to largely increse qc of both forward and backward (The setting still meet the minimum requirement of merge in dada2: 20 bps)
# result: not good.
qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 189 --p-trunc-len-r 160 --p-trim-left-f 3 --p-trim-left-r 3 --p-n-threads 8 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2-6
done

#### test conclusion ###########
# I'm sorry that I have no way to balance various merge percentages by only one setting of parameters. I think this is due to the batch sequencing effect. I try my best to get the largest merge percentage across all samples.
# Since no-cut at right ends will guarantee the equal length of finally merged sequences (~253 bps), I recommend to separate potentially batch-effected samples and then use different parameters of left-truncate site to separately imporve their merge percentage. However, this process maybe very time-comsuming.
