#!/bin/bash
# author: Yufei Zeng
# zengyf93@qq.com
echo "######################################################"
echo "Please activate qiime2 environment before tree work"
echo "Temporary use for Yang lab"
echo "######################################################"
echo "                           "
echo "----------------now loading your representative sequences----------------"
qiime tools import --type 'FeatureData[Sequence]' --input-path ${1} --output-path rep-seqs.qza
#### TAXA
##### phylogenetic tree
# mafft to align seqs
qiime alignment mafft --i-sequences rep-seqs.qza --o-alignment aligned-rep-seqs.qza

# mask
# why mask: avoid the effect of low-complexity sequences to alignment algorithms
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza

# FASTTREE to built a tree
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree fasttree-tree.qza

# Root the tree: make the distance comparable.
qiime phylogeny midpoint-root --i-tree fasttree-tree.qza --o-rooted-tree rooted-fasttree-tree.qza

# export the tree and aligned seqs
qiime tools export --input-path rooted-fasttree-tree.qza --output-path phylo_tree
echo "----------------work done------------"
