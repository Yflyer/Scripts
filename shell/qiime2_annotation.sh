#!/bin/bash
# author: Yufei Zeng
# zengyf93@qq.com
echo "######################################################"
echo "Please activate qiime2 environment before annotations"
echo "Temporary use for Yang lab"
echo "######################################################"
echo "                           "
echo "----------------now loading your representative sequences----------------"
qiime tools import --type 'FeatureData[Sequence]' --input-path ${1} --output-path rep-seqs.qza
#### TAXA
qiime feature-classifier classify-sklearn --p-n-jobs 10 --p-pre-dispatch 1 --i-classifier  ${2} --i-reads rep-seqs.qza  --o-classification taxonomy.qza
qiime tools export  --input-path taxonomy.qza --output-path annotations
echo "----------------work donw------------"
