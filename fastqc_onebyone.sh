#! /bin/bash
# this script is used for individually fastqc sample of shotgun

for i in `ls *.gz`;
do
    fastqc ${i}
done