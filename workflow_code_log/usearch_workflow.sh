############################### start your project ###############################
# In project dir
mkdir usearch
cd usearch

############################### sample paired-reads merge ########################
# Add sample name to read labels (-relabel @ option)
# Pool samples together into raw.fq
# pnly work when sample name: **_R1*** (in fastq format, no gz; no _ or - in sample name; letter in the begin)
# Paired read merging should be done before quality filtering because the posterior Q scores in the overlapping region are more accurate.
usearch -fastq_mergepairs ../0_rawdata/*R1.fq -relabel @ -fastqout raw.fq

###################### remove primer ################################
# Primer stripping should be done before
# a. quality filtering (because every base causes an increase in expected errors) 
# b. finding unique sequences (because variation in the primer-binding region will split over biological sequence over several uniques, degrading the calculation of unique sequence abundance).
# subset a large file if need
usearch -fastx_subsample raw.fq -sample_pct 1 -randseed 1 -fastaout one_pct_test.fq
# 16S
cat > primers.fa <<eof
>forward
GTGCCAGCMGCCGCGGTAA
>reverse
CCGTCAATTCMTTTRAGTTT
eof
usearch -search_oligodb one_pct_test.fq -db primers.fa -strand both \
  -userout primer_hits.txt -userfields query+qlo+qhi+qstrand -threads 15
# ITS
cat > primers.fa <<eof
>forward
CTTGGTCATTTAGAGGAAGTAA
>reverse
GCTGCGTTCTTCATCGATGC
eof
usearch -search_oligodb one_pct_test.fq -db primers.fa -strand both \
  -userout primer_hits.txt -userfields query+qlo+qhi+qstrand -threads 15

# turncate according the above result
usearch -fastx_truncate raw.fq -stripleft 20 -stripright 21 -fastqout stripped.fq 

# Quality filter
usearch -fastq_filter stripped.fq -fastq_maxee 1.0 \
  -fastaout filtered.fa -relabel Filt -threads 15

# Find unique read sequences and abundances
usearch -fastx_uniques filtered.fa -sizeout -relabel Uniq -fastaout uniques.fa -threads 15

# Run UPARSE algorithm to make 97% OTUs
usearch -cluster_otus uniques.fa -otus otus.fa -relabel Otu -threads 15

# Run UNOISE algorithm to get denoised sequences (ZOTUs)
#usearch -unoise3 uniques.fa -zotus zotus.fa -threads 15

# Downstream analysis of OTU sequences & OTU table
# Can do this for both OTUs and ZOTUs, here do
# just OTUs to keep it simple.
##################################################

# Make OTU table
usearch -otutab raw.fq -otus otus.fa -otutabout otutab_raw.txt -threads 15

# Make OTU tree
usearch -calc_distmx otus.fa -tabbedout distmx.txt -threads 15
usearch -cluster_aggd distmx.txt -treeout otus.tree -threads 15

# Predict taxonomy
usearch -sintax otus.fa -db /vd03/home/MetaDatabase/Silva_132_release/SILVA_132_USEARCH/SILVA_132_16s_SSURef_Nr99_Usearch.fasta -strand both \
  -tabbedout sintax.txt -sintax_cutoff 0.8 -threads 15

# Taxonomy summary reports
usearch -sintax_summary sintax.txt -otutabin otutab.txt -rank g -output genus_summary.txt
usearch -sintax_summary sintax.txt -otutabin otutab.txt -rank p -output phylum_summary.txt
