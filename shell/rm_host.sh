### remove host
# database:

mkdir 01_rmhost
cd 01_rmhost
ln -s ../01_cleandata/S*/*Trimmed* ./

for filename in *_R1.Trimmed.fq.gz
do
  #Use the program basename to remove _R1.Trimmed.fq.gz to generate the base
  base=$(basename $filename _R1.Trimmed.fq.gz)
  echo $base

  kneaddata -i ${base}_R1.Trimmed.fq.gz -i  ${base}_R2.Trimmed.fq.gz \
  -o 01_rmhost/ -v -t 8 --remove-intermediate-output \
  --bypass-trim \
  --bowtie2-options '--very-sensitive --dovetail' \
  --bowtie2-options="--reorder" \
  -db $DTB/Homo_sapiens
done

kneaddata_read_count_table --input 01_rmhost --output kneaddata_sum.txt



'''
kneaddata -i S1977296_R1.Trimmed.fq.gz -i S1977296_R2.Trimmed.fq.gz \
-o 01_rmhost/ -v -t 8 --remove-intermediate-output \
--trimmomatic ~/anaconda3/envs/py35/share/trimmomatic \
 --trimmomatic-options 'ILLUMINACLIP:~/anaconda3/envs/py35/share/trimmomatic/adapters/TruSeq3-PE.fa:2:40:15 SLIDINGWINDOW:4:20 MINLEN:50' \
 --bowtie2-options '--very-sensitive --dovetail' \
 --bowtie2-options="--reorder" \
 -db $DTB/Homo_sapiens
'''
