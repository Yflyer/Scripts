# 132 samples, L-sampling methods, 12 samples per site.

# r1/r2 reversed, please check mapping
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path mapping.tsv --output-path demux.qza --input-format PairedEndFastqManifestPhred33V2
qiime demux summarize --i-data demux.qza --o-visualization demux.qzv
qiime tools export  --input-path demux.qzv --output-path result/0_seq-qc

qiime cutadapt trim-paired --i-demultiplexed-sequences demux.qza --p-front-f GTGCCAGCMGCCGCGGTAA --p-front-r CCGTCAATTCMTTTRAGTTT --p-minimum-length 210 --o-trimmed-sequences trim-demux.qza --p-discard-untrimmed true
qiime demux summarize --i-data trim-demux.qza --o-visualization trim-demux.qzv
qiime tools export  --input-path trim-demux.qzv --output-path result/1_trim-seq-qc

# dada2 turncate
qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 222 --p-trunc-len-r 212 --p-min-fold-parent-over-abundance 8 --p-n-threads 10 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza

for i in `ls dada2*.qza`; do
    qiime tools export --input-path ${i} --output-path result/2-dada2
done

qiime alignment mafft --i-sequences dada2-rep-seqs.qza --o-alignment aligned-rep-seqs.qza
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree fasttree-tree.qza
qiime phylogeny midpoint-root --i-tree fasttree-tree.qza --o-rooted-tree rooted-fasttree-tree.qza
qiime feature-classifier classify-sklearn --p-n-jobs 10 --p-pre-dispatch 1 --i-classifier  $DTB/silva_16s_classifier/99_16S_silva_F515_R926_classifier.qza --i-reads dada2-rep-seqs.qza  --o-classification taxonomy.qza
qiime tools export  --input-path taxonomy.qza --output-path result/3_classification
qiime tools export --input-path rooted-fasttree-tree.qza --output-path result/4_tree/fasttree
qiime tools export --input-path aligned-rep-seqs.qza --output-path result/4_tree


# dada2 no-turncate
qiime dada2 denoise-paired --i-demultiplexed-seqs demux.qza --p-trunc-len-f 0 --p-trunc-len-r 0 --p-min-fold-parent-over-abundance 8 --p-n-threads 10 --o-table dada2-table.qza --o-representative-sequences dada2-rep-seqs.qza --o-denoising-stats dada2-denoising-stats.qza
