### in this code, we used 2020/02/04 99% version unite to train classifier
# upper the letter in reads of refs fasta
awk '/^>/ {print($0)}; /^[^>]/ {print(toupper($0))}' sh_refs_qiime_ver8_99_04.02.2020_dev.fasta | tr -d ' ' > sh_refs_qiime_ver8_99_04.02.2020_dev_uppercase.fasta

qiime tools import --type 'FeatureData[Sequence]' --input-path sh_refs_qiime_ver8_99_04.02.2020_dev_uppercase.fasta --output-path unite-ver8-99-refs.qza
qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path sh_taxonomy_qiime_ver8_99_04.02.2020_dev.txt --output-path unite-ver8-99-tax.qza
qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads unite-ver8-99-refs.qza --i-reference-taxonomy unite-ver8-99-tax.qza --o-classifier unite-ver8-99_classifier.qza


qiime alignment mafft --i-sequences UPARSE_rep_seq.qza --o-alignment aligned-rep-seqs.qza
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree fasttree-tree.qza
qiime phylogeny midpoint-root --i-tree fasttree-tree.qza --o-rooted-tree rooted-fasttree-tree.qza
qiime feature-classifier classify-sklearn --i-classifier  $DTB/silva_16s_classifier/99_16S_silva_F515_R806_classifier.qza --i-reads UPARSE_rep_seq.qza  --o-classification taxonomy.qza
qiime tools export  --input-path taxonomy.qza --output-path result/3_classification
qiime tools export --input-path rooted-fasttree-tree.qza --output-path result/4_tree/fasttree
qiime tools export --input-path aligned-rep-seqs.qza --output-path result/4_tree

biom convert -i feature-table.biom -o feature-table.tsv --to-tsv
