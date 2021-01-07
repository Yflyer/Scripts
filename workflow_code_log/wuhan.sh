parallel -j 10 --xapply -k 'samtools view -b -@ 8 -F 4 -f 8 {1} > mf.{1}' ::: inter*sam
parallel -j 10 --xapply -k 'samtools view -b -@ 8 -F 8 -f 4 {1} > mr.{1}' ::: inter*sam
parallel -j 10 --xapply -k 'samtools view -b -@ 8 -F 12 {1} > mp.{1}' ::: inter*sam
parallel -j 10 --xapply -k 'samtools view -@ 8 -bS {1} > {1.}.bam' ::: merge.inter*.sam

parallel -j 10 --xapply -k 'samtools sort -n -m 6G -@ 8 {1} -o sorted.{1}' ::: mp.inter*.bam
parallel -j 10 --xapply -k 'samtools view -@ 8 -bS {1} > {1.}.bam' ::: sorted.mp.inter*.sam

for i in sorted.mp.inter*bam; do   genomeCoverageBed -ibam $i > coverage_result/${i/sorted.mp.interleaved./}.histogram.tab; done
for i in *.tab; do python coverage.py $i; done
for i in *.coverage.tab; do name=$(basename $i .bam.histogram.tab.coverage.tab); awk -v name=$name 'NR>1 {print name "\t" $0}' $i >> result.txt; done
