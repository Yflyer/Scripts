# import ref seq and taxonomy
qiime tools import --type 'FeatureData[Sequence]' --input-path /vd02/home3/test_data/silva_132_99_16S.fna --output-path 99_16S_silva_ref_seq.qza

qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path /vd02/home3/test_data/16S_majority_taxonomy_7_levels.txt --output-path 99_16S_silva_ref_taxonomy.qza

# we extract reads on F515 to R806 to imporve accuracy
qiime feature-classifier extract-reads --i-sequences 99_16S_silva_ref_seq.qza --p-f-primer GTGYCAGCMGCCGCGGTAA --p-r-primer GGACTACNVGGGTWTCTAAT --p-min-length 200 --p-max-length 290 --o-reads trim_99_16S_silva_ref_seq.qza
qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads trim_99_16S_silva_ref_seq.qza --i-reference-taxonomy 99_16S_silva_ref_taxonomy.qza --o-classifier 99_16S_silva_F515_R806_classifier.qza

# we extract reads on F515 to R926 to imporve accuracy
qiime feature-classifier extract-reads --i-sequences 99_16S_silva_ref_seq.qza --p-f-primer GTGYCAGCMGCCGCGGTAA --p-r-primer CCGTCAATTCMTTTRAGTTT --p-min-length 360 --p-max-length 430 --o-reads trim_99_16S_silva_ref_seq.qza
qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads trim_99_16S_silva_ref_seq.qza --i-reference-taxonomy 99_16S_silva_ref_taxonomy.qza --o-classifier 99_16S_silva_F515_R926_classifier.qza

####
for i in *.fasta
do
qiime tools import --type 'FeatureData[Sequence]' --input-path ${i} --output-path ${i}.qza
qiime alignment mafft --i-sequences ${i}.qza --o-alignment aligned-rep-seqs.qza
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree fasttree-tree.qza
qiime phylogeny midpoint-root --i-tree fasttree-tree.qza --o-rooted-tree rooted-fasttree-tree.qza
qiime tools export --input-path rooted-fasttree-tree.qza --output-path result/${i}/fasttree
done

qiime feature-classifier classify-sklearn --i-classifier  $DTB/silva_16s_classifier/99_16S_silva_F515_R806_classifier.qza --i-reads UPARSE_rep_seq.qza  --o-classification taxonomy.qza
qiime tools export  --input-path taxonomy.qza --output-path result/3_classification
qiime tools export --input-path rooted-fasttree-tree.qza --output-path result/4_tree/fasttree
qiime tools export --input-path aligned-rep-seqs.qza --output-path result/4_tree

biom convert -i feature-table.biom -o feature-table.tsv --to-tsv
