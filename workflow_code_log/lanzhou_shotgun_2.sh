export PATH=$PATH:/vd03/home/yufei/scripts
export DTB=$DTB/vd03/home/MetaDatabase
export SGENV=$SGENV/vd03/home/public_conda_envs/py36/share

mkdir 00_rawdata
cd 00_rawdata
parallel -j 8 gzip -k -d ::: *.gz

mkdir 01_cleandata
cd 01_cleandata

ln -s ../00_rawdata/*fq ./

parallel -j 3 --xapply 'echo {1} {2}'  ::: *_R1.fq ::: *_R2.fq
parallel -j 3 --xapply 'kneaddata -i {1} -i {2} -o kneaddata_out -v \
-db /mnt/f/database/Human_bowtie2  \
--trimmomatic ~/anaconda3/envs/py35/share/trimmomatic --trimmomatic-options "ILLUMINACLIP:~/anaconda3/envs/py35/share/trimmomatic/adapters/TruSeq3-PE.fa:2:40:15 SLIDINGWINDOW:4:20 MINLEN:50" \
-t 6 --bowtie2-options "--very-sensitive --dovetail" --remove-intermediate-output' \
 ::: *_R1.fq ::: *_R2.fq

parallel -j 3 --xapply 'kneaddata -i {1} -i {2} -o kneaddata_out -v \
 -db $DTB/Human_bowtie2  \
 --trimmomatic $SGENV/trimmomatic --trimmomatic-options "ILLUMINACLIP:TruSeq3-PE.fa:2:40:15 SLIDINGWINDOW:4:20 MINLEN:50" \
 -t 6 --bowtie2-options "--very-sensitive --dovetail" --remove-intermediate-output' \
  ::: *_R1.fq ::: *_R2.fq
