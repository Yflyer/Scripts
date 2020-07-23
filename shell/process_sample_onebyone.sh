#! /bin/bash
# this script is used for individually processing sample of shotgun
if test -e ${1}
then
  echo "The data will be processed in \"${1}\""
else
    mkdir $1
    echo "\"${1}\" has been created. Data will be processed there."
fi


for i in `ls *.gz`;
do
    cp ${i} ${1}/${i}
    cd ${1}

    ###put the scripts at following area:
    # for example:
    sample=$(gunzip ${i})

    ### use a test command to rm previous file and release the room
    if test -e ${sample}
    then
      echo "The work of ${i} has been completed"
      rm ${i}
    else
      echo "Something wrong. Please check"
    fi

    cd $OLDPWD
done

for i in *sra
do
echo $i
fastq-dump --split-3 $i
done
for i in *fastq
do
cp $i /mnt/
fastq-dump --split-3 $i
done
