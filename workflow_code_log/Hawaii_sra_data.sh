# /mnt/f/Hawaii_rawdata/available_rawdata/
###
mapping_by_sra.py --sra SraRunTable.txt --input sra --format txt --type BAC

##################16s
### merge
merge_fasta_qiime1.py split_all/ -- Hawaii_16s.fasta

######################
## fna cluster
qiime tools import \
  --input-path Hawaii_16s.fasta \
  --output-path seqs.qza \
  --type 'SampleData[Sequences]'

qiime vsearch dereplicate-sequences \
  --i-sequences seqs.qza \
  --o-dereplicated-table table.qza \
  --o-dereplicated-sequences rep-seqs.qza

qiime vsearch cluster-features-closed-reference \
  --i-table table.qza \
  --i-sequences rep-seqs.qza \
  --i-reference-sequences $DTB/silva_16s_classifier/97_16S_silva_ref_seq.qza \
  --p-perc-identity 0.97 \
  --p-threads 8 \
  --o-clustered-table otu-table.qza \
  --o-clustered-sequences otu-rep-seqs.qza \
  --o-unmatched-sequences unmatched.qza

qiime feature-table filter-features \
  --i-table otu-table.qza \
  --p-min-frequency 2 \
  --o-filtered-table otu-table.qza

qiime tools export --input-path otu-table.qza --output-path vsearch_result/2-otu_table
biom convert -i vsearch_result/2-otu_table/feature-table.biom -o vsearch_result/2-otu_table/feature-table.tsv --to-tsv

qiime alignment mafft --i-sequences otu-rep-seqs.qza --o-alignment aligned-rep-seqs.qza
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree fasttree-tree.qza
qiime phylogeny midpoint-root --i-tree fasttree-tree.qza --o-rooted-tree rooted-fasttree-tree.qza
qiime feature-classifier classify-sklearn --i-classifier  $DTB/silva_16s_classifier/97_16S_silva_F515_R806_classifier.qza --i-reads rep-seqs-or-97.qza  --o-classification taxonomy.qza
### out put
qiime tools export  --input-path taxonomy.qza --output-path vsearch_result/3_classification
qiime tools export --input-path rooted-fasttree-tree.qza --output-path vsearch_result/4_tree/fasttree
qiime tools export --input-path aligned-rep-seqs.qza --output-path vsearch_result/4_tree

###
### vsearch
qiime vsearch cluster-features-de-novo \
  --i-table table.qza \
  --i-sequences rep-seqs.qza \
  --p-perc-identity 0.97 \
  --p-threads 8 \
  --o-clustered-table otu-table.qza \
  --o-clustered-sequences otu-rep-seqs.qza
####


####################################### ITS
### Multiplexed paired-end FASTQ with barcodes in sequence
###
demux_by_bcseq.py --bcsample barcode-ITS\ Eric\ Dubinsky\ 10302015.txt --r1 Undetermined_S0_L001_R1_001.fastq --r2 Undetermined_S0_L001_R2_001.fastq --bcseq Undetermined_S0_L001_I1_001.fastq


qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path paired-seq \
  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
  --output-path multiplexed-seqs.qza


qiime cutadapt demux-single \
  --i-seqs multiplexed-seqs.qza \
  --m-forward-barcodes-file metadata.tsv \
  --m-forward-barcodes-column Barcode \
  --p-error-rate 0 \
  --o-per-sample-sequences demultiplexed-seqs.qza \
  --o-untrimmed-sequences untrimmed.qza \

qiime vsearch dereplicate-sequences \
  --i-sequences seqs.qza \
  --o-dereplicated-table table.qza \
  --o-dereplicated-sequences rep-seqs.qza

### vsearch
qiime vsearch cluster-features-closed-reference \
  --i-table table.qza \
  --i-sequences rep-seqs.qza \
  --i-reference-sequences $DTB/silva_16s_classifier/97_16S_silva_ref_seq.qza \
  --p-perc-identity 0.97 \
  --p-threads 8 \
  --o-clustered-table otu-table.qza \
  --o-clustered-sequences rep-seqs.qza \
  --o-unmatched-sequences unmatched.qza

qiime vsearch cluster-features-de-novo \
  --i-table table.qza \
  --i-sequences rep-seqs.qza \
  --p-perc-identity 0.97 \
  --p-threads 8 \
  --o-clustered-table otu-table.qza \
  --o-clustered-sequences otu-rep-seqs.qza

qiime feature-table filter-features \
  --i-table otu-table.qza \
  --p-min-frequency 2 \
  --o-filtered-table otu-table.qza
