#!/bin/bash
# Yufei Zeng
# 2021/06/28
# yfzeng0827@hotmail.com

### two kind of errors in SRA download:
### 1. net conection failed
### 2. missed by prefecch --file
### check miss in prefetch file
ls *.sra | cut -d '.' -f1 > completed.run.txt
# use grep get miss file
grep -v -f completed.run.txt ../SRR_Acc_List.txt.csv > uncompleted.run.txt

### use while to repeatly check whether uncompleted sra number left. And then refresh it every time after a successful prefetch.
while (($(cat uncompleted.run.txt | wc -l)>0))
do
  prefetch --option-file uncompleted.run.txt --output-directory .
  # refresh the uncompleted list
  ls *.sra | cut -d '.' -f1 > completed.run.txt
  grep -v -f completed.run.txt ../SRR_Acc_List.txt.csv > uncompleted.run.txt
done

rm uncompleted.run.txt
rm completed.run.txt
echo 'All SRA list has been checked and downloaded'
