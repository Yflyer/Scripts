# unique kmer trimed

mkdir -p 01_kmer_trim
cd 01_kmer_trim
ln -s ../01_cleandata/S*/*Trimmed* ./

for filename in *_R1.Trimmed.fq.gz
do
  #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  base=$(basename $filename _R1.Trimmed.fq.gz)
  echo $base

  interleave-reads.py ${base}_R1.Trimmed.fq.gz ${base}_R2.Trimmed.fq.gz | \
  trim-low-abund.py - -V -Z 10 -C 3 -o - --gzip -M 8e9 | \
  extract-paired-reads.py --gzip -p ${base}_khmer_pe.fq.gz -s ${base}_khmer_se.fq.gz
done



unique-kmers.py TARA_135_SRF_5-20_rep1_1m_1.qc.fq.gz TARA_135_SRF_5-20_rep1_1m_2.qc.fq.gz
unique-kmers.py TARA_135_SRF_5-20_rep1_1m.khmer.pe.fq.gz

cd khmer_trim
