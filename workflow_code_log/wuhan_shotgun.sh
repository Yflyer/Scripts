parallel -j 20 --xapply 'trimmomatic PE -phred33 -threads 4 {1} {2} \
      trimmed.{1.} outtrimmed.{1.} trimmed.{2.} outtrimmed.{2.}  \
      ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
      SLIDINGWINDOW:5:20 LEADING:5 TRAILING:5 \
      MINLEN:50' ::: *R1.fq.gz ::: *R2.fq.gz


parallel -j 25 --xapply 'bowtie2 -p 4 -x ../sars-cov-2/sars-cov-2 --very-sensitive-local --dovetail --mp 2,2 -1 {1} -2 {2} -S {1.}.sam' ::: trimmed.*1.fq ::: trimmed.*2.fq
parallel -j 10 --xapply -k 'samtools view -@ 8 -bS {1} > {1.}.bam' ::: *.sam
