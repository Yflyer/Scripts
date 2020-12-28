# /mnt/f/Hawaii_rawdata/available_rawdata/
###
mapping_by_sra.py --sra SraRunTable.txt --input sra --format txt --type BAC


########
####### ITS
Split_libraries_fastq.pl --f1 Hawaii_ITS_S0_L001_R1_001.fastq --f2 Hawaii_ITS_S0_L001_R2_001.fastq --map sample.tab --index Hawaii_ITS_S0_L001_I1_001.fastq --o1 Hawaii_ITS_R1.fq --o2 Hawaii_ITS_R2.fq

split_by_tag.py Hawaii_ITS_R1.fq 00_rawdata/r1 --
split_by_tag.py Hawaii_ITS_R2.fq 00_rawdata/r2 --

mkdir -p 01_cleandata
mkdir -p 01_cleandata/r1
mkdir -p 01_cleandata/r2
pair_check_by_files.py --r1 00_rawdata/r1 --r2 00_rawdata/r2 --output 01_cleandata

cd 01_cleandata/r1
for i in *.fastq;
do
    cutadapt -g GTGARTCATCGARTCTTTG -o ptrim_${i} -m 150 -M 350 --trimmed-only --max-n 0 -j 8 ${i} > ../../ptrim_r1_report_txt
    rm ${i}
done

cd ../r2
for i in *.fastq;
do
    cutadapt -g TCCTCCGCTTATTGATATGC -o ptrim_${i} -m 150 -M 350 --trimmed-only --max-n 0 -j 8 ${i} > ../../ptrim_r2_report_txt
    rm ${i}
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
