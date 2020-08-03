############# workflow code ######################

####### split, clean and cut primers
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
make_mapping_qiime2.py 01_cleandata/r1 01_cleandata/r2

####### QIIME2 workflow
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path mapping.tsv --output-path demux.qza --input-format PairedEndFastqManifestPhred33V2
qiime demux summarize --i-data demux.qza --o-visualization demux.qzv
qiime tools export  --input-path demux.qzv --output-path result/1_seq-qc

qiime cutadapt trim-paired --i-demultiplexed-sequences demux.qza --p-front-f GTGCCAGCMGCCGCGGTAA --p-front-r GGACTACHVGGGTWTCTAAT --p-minimum-length 200 --o-trimmed-sequences trim-demux.qza --p-discard-untrimmed true

pair_check_by_files.py --r1 r1 --r2 r2 --output paircheck

# acording to seq qc result, the turncate length at left site should be 224 and 183. Since no turncate at right side, the merge length should be ~252
qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 224 --p-trunc-len-r 224 --p-n-threads 7 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2-1
done

# the merge percentage of samples is not good. So I have to extend the turncate length at left side to make sure merge.
qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 224 --p-trunc-len-r 183 --p-n-threads 7 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2-2
done

qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 210 --p-trunc-len-r 160 --p-n-threads 7 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2-3
done
