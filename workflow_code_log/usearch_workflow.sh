# Add sample name to read labels (-relabel @ option)
# Pool samples together into raw.fq
$usearch -fastq_mergepairs ../data/*_R1.fastq -relabel @ -fastqout raw.fq

# Quality filter
$usearch -fastq_filter raw.fq -fastq_maxee 1.0 \
  -fastaout filtered.fa -relabel Filt

# Find unique read sequences and abundances
$usearch -fastx_uniques filtered.fa -sizeout -relabel Uniq -fastaout uniques.fa

# Run UPARSE algorithm to make 97% OTUs
$usearch -cluster_otus uniques.fa -otus otus.fa -relabel Otu

# Run UNOISE algorithm to get denoised sequences (ZOTUs)
$usearch -unoise3 uniques.fa -zotus zotus.fa

# Downstream analysis of OTU sequences & OTU table
# Can do this for both OTUs and ZOTUs, here do
# just OTUs to keep it simple.
##################################################

# Make OTU table
$usearch -otutab raw.fq -otus otus.fa -otutabout otutab_raw.txt

# Normalize to 5k reads / sample
$usearch -otutab_norm otutab_raw.txt -sample_size 5000 -output otutab.txt

# Alpha diversity
$usearch -alpha_div otutab.txt -output alpha.txt

# Make OTU tree
$usearch -calc_distmx otus.fa -tabbedout distmx.txt
$usearch -cluster_aggd distmx.txt -treeout otus.tree

# Beta diversity
mkdir beta/
$usearch -beta_div otutab.txt -tree otus.tree -filename_prefix beta/

# Rarefaction
$usearch -alpha_div_rare otutab.txt -output alpha_rare.txt

# Predict taxonomy
$usearch -sintax otus.fa -db ../data/rdp_its_v2.fa -strand both \
  -tabbedout sintax.txt -sintax_cutoff 0.8

# Taxonomy summary reports
$usearch -sintax_summary sintax.txt -otutabin otutab.txt -rank g -output genus_summary.txt
$usearch -sintax_summary sintax.txt -otutabin otutab.txt -rank p -output phylum_summary.txt
