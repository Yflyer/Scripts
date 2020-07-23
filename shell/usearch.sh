usearch -fastx_uniques merge.fasta -fastaout uniques.fa -sizeout -relabel Uniq
usearch -cluster_otus uniques.fa -otus otus.fa -uparseout uparse.txt -relabel Otu -threads 60
