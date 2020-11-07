# 132 samples, L-sampling methods, 12 samples per site.

qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path mapping.tsv --output-path demux.qza --input-format PairedEndFastqManifestPhred33V2
qiime demux summarize --i-data demux.qza --o-visualization demux.qzv
qiime tools export  --input-path demux.qzv --output-path result/0_seq-qc

qiime cutadapt trim-paired --i-demultiplexed-sequences demux.qza --p-front-f GTGARTCATCGARTCTTTG --p-front-r TCCTCCGCTTATTGATATGC --p-minimum-length 200 --o-trimmed-sequences trim-demux.qza --p-discard-untrimmed true
qiime demux summarize --i-data trim-demux.qza --o-visualization trim-demux.qzv
qiime tools export  --input-path trim-demux.qzv --output-path result/1_trim-seq-qc
