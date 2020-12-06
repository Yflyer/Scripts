### in this code, we used 2020/02/04 99% version unite to train classifier
# upper the letter in reads of refs fasta
awk '/^>/ {print($0)}; /^[^>]/ {print(toupper($0))}' sh_refs_qiime_ver8_99_04.02.2020_dev.fasta | tr -d ' ' > sh_refs_qiime_ver8_99_04.02.2020_dev_uppercase.fasta

########### pr-2
qiime tools import --type 'FeatureData[Sequence]' --input-path pr2_version_4.12.0_18S_mothur.fasta --output-path pr2-18S-refs.qza
qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path  pr2_version_4.12.0_18S_mothur.tax --output-path pr2-18S-tax.qza
qiime feature-classifier extract-reads --i-sequences pr2-18S-refs.qza --p-f-primer CCAGCASCYGCGGTAATTCC --p-r-primer  ACTTTCGTTCTTGATYRA --p-min-length 200 --p-max-length 480 --o-reads trim-pr2-18S-refs.qza
qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads trim-pr2-18S-refs.qza --i-reference-taxonomy pr2-18S-tax.qza --o-classifier trim-pr2-18S_classifier.qza

########### silva
qiime tools import --type 'FeatureData[Sequence]' --input-path silva_132_99_18S.fna --output-path 99_18S_silva_ref_seq.qza
qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path taxonomy_7_levels.txt --output-path 99_18S_silva_ref_taxonomy.qza
qiime feature-classifier extract-reads --i-sequences 99_18S_silva_ref_seq.qza --p-f-primer CCAGCASCYGCGGTAATTCC --p-r-primer ACTTTCGTTCTTGATYRA --p-min-length 200 --p-max-length 500 --o-reads trim_99_18S_silva_ref_seq.qza
qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads trim_99_18S_silva_ref_seq.qza --i-reference-taxonomy 99_18S_silva_ref_taxonomy.qza --o-classifier trim_99_18S_silva_classifier.qza

qiime alignment mafft --i-sequences UPARSE_rep_seq.qza --o-alignment aligned-rep-seqs.qza
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree fasttree-tree.qza
qiime phylogeny midpoint-root --i-tree fasttree-tree.qza --o-rooted-tree rooted-fasttree-tree.qza
qiime feature-classifier classify-sklearn --i-classifier  $DTB/silva_16s_classifier/99_16S_silva_F515_R806_classifier.qza --i-reads UPARSE_rep_seq.qza  --o-classification taxonomy.qza
qiime tools export  --input-path taxonomy.qza --output-path result/3_classification
qiime tools export --input-path rooted-fasttree-tree.qza --output-path result/4_tree/fasttree
qiime tools export --input-path aligned-rep-seqs.qza --output-path result/4_tree

biom convert -i feature-table.biom -o feature-table.tsv --to-tsv
