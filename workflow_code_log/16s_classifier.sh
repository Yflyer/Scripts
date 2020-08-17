

qiime tools import --type 'FeatureData[Sequence]' --input-path UPARSE_rep_seq.fasta --output-path UPARSE_rep_seq.qza

qiime alignment mafft --i-sequences UPARSE_rep_seq.qza --o-alignment aligned-rep-seqs.qza
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree fasttree-tree.qza
qiime phylogeny midpoint-root --i-tree fasttree-tree.qza --o-rooted-tree rooted-fasttree-tree.qza
qiime feature-classifier classify-sklearn --i-classifier  $DTB/silva_16s_classifier/99_16S_silva_F515_R806_classifier.qza --i-reads UPARSE_rep_seq.qza  --o-classification taxonomy.qza
qiime tools export  --input-path taxonomy.qza --output-path result/3_classification
qiime tools export --input-path rooted-fasttree-tree.qza --output-path result/4_tree/fasttree
qiime tools export --input-path aligned-rep-seqs.qza --output-path result/4_tree

biom convert -i feature-table.biom -o feature-table.tsv --to-tsv
