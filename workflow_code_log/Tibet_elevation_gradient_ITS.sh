# 132 samples, L-sampling methods, 12 samples per site.

qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path mapping.tsv --output-path demux.qza --input-format PairedEndFastqManifestPhred33V2
qiime demux summarize --i-data demux.qza --o-visualization demux.qzv
qiime tools export  --input-path demux.qzv --output-path result/0_seq-qc

qiime cutadapt trim-paired --i-demultiplexed-sequences demux.qza --p-front-f CTTGGTCATTTAGAGGAAGTAA --p-front-r GCTGCGTTCTTCATCGATGC --p-minimum-length 200 --o-trimmed-sequences trim-demux.qza --p-discard-untrimmed true
qiime demux summarize --i-data trim-demux.qza --o-visualization trim-demux.qzv
qiime tools export  --input-path trim-demux.qzv --output-path result/1_trim-seq-qc

qiime feature-classifier classify-sklearn --p-n-jobs 10 --p-pre-dispatch 1 --i-classifier  $DTB/unite_ITS_classifier/unite-ver8-99_classifier.qza --i-reads dada2-rep-seqs.qza  --o-classification taxonomy.qza
qiime tools export  --input-path taxonomy.qza --output-path result/3_classification

qiime alignment mafft --i-sequences dada2-rep-seqs.qza --o-alignment aligned-rep-seqs.qza
mafft --thread 6 --parttree --retree 1 dna-sequences.fasta > algined-seq.fasta
awk '/^>/ {print($0)}; /^[^>]/ {print(toupper($0))}' result/2-dada2/algined-seq.fasta | tr -d ' ' > result/2-dada2/algined-seq-uppercase.fasta

qiime tools import --type 'FeatureData[AlignedSequence]' --input-path result/2-dada2/algined-seq.fasta --output-path aligned-rep-seqs.qza
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree fasttree-tree.qza
qiime phylogeny midpoint-root --i-tree fasttree-tree.qza --o-rooted-tree rooted-fasttree-tree.qza
qiime tools export --input-path rooted-fasttree-tree.qza --output-path result/4_tree/fasttree
qiime tools export --input-path aligned-rep-seqs.qza --output-path result/4_tree
