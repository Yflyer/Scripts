usearch -fastx_uniques merge.fasta -fastaout uniques.fa -sizeout -relabel Uniq
usearch -cluster_otus uniques.fa -otus otus.fa -uparseout uparse.txt -relabel Otu -threads 60


usearch -sintax example.fa -db test.fa -tabbedout test.tb -strand both -sintax_cutoff 0.5
usearch -makeudb_usearch SILVA_132_16s_SSURef_Nr99_Usearch.fasta -output test.udb
usearch -sintax otus.fa -db test.udb -tabbedout test.tb -strand both -sintax_cutoff 0.5 --threads 40
