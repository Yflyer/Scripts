$ paste <(cat header.txt) <(cat input.fasta  | paste - - | cut -c 2-)  | awk '{printf(">%s_%s\n%s\n",$1,$2,$3);}'

cat input.fasta  | paste - - | cut -c 2- | sed -e 's/^/${i}/'

awk '{print "Root " $0}' <(cat input.fasta  | paste - - | cut -c 2-)
-v awkvar="$myvar"
awk -v prefix="$prefix" '{printf(">prefix_%s\n%s\n",$1,$2);}' <(cat input.fasta  | paste - - | cut -c 2-)

echo | awk -v prefix="$prefix" '{print >prefix;}'
echo | awk -v prefix="$prefix" '{ print prefix; }'

awk -v prefix="$prefix" '{printf(">prefix_%s\n%s\n",$1,$2);}' <()
cat test.fasta  | paste - - | cut -d 2- | awk -v prefix="$prefix" '{ print ">"prefix"_"$1"\n"$2; }' > test.fasta

for i in sample_list.txt
do
  cat ${i}.contigs.fa  | paste - - | cut -c 2- | awk -v prefix="$i" '{ print ">"prefix"_"$1"\n"$2; }' > ${i}.contigs.fa
done

sed -i "s/>/>$prefix\_/1" test.fa

while read prefix
do
  sed -i "s/>/>$prefix\_/1" ${prefix}.contigs.fa
done < sample_list.txt

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/eco925/miniconda2/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/eco925/miniconda2/etc/profile.d/conda.sh" ]; then
        . "/home/eco925/miniconda2/etc/profile.d/conda.sh"
    else
        export PATH="/home/eco925/miniconda2/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
