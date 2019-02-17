#!/bin/bash
#
#SBATCH -t 5-00                    # time (D-HH:MM)
#SBATCH -o slurm.%N.%j.SCNorm.out           # STDOUT
#SBATCH -e slurm.%N.%j.SCNorm.err           # STDERR

method=$1
lfc=$2
pval=$3

chemin=`pwd`

listefile=`ls SCNorm/param`

if [ ! -d "SCNorm/tmp" ]
then
    mkdir SCNorm/tmp
fi

DATE=`date '+%Y-%m-%d-%H-%M-%S'`

mkdir SCNorm/tmp/$DATE

for nfile in $listefile
do
  header=`head -n 1 SCNorm/param/$nfile`
  nline=`cat SCNorm/param/$nfile | wc -l`
  i=2
  while [ $i -le $nline ]
  do
    echo "$header" > SCNorm/tmp/$DATE/${nfile}Param$i.csv
    line=`sed -n "${i}{p;q}" SCNorm/param/$nfile`
    echo "$line" >> SCNorm/tmp/$DATE/${nfile}Param${i}.csv
    i=$((i+1))
  done

done

listefile=`ls SCNorm/tmp/$DATE`

for nfile in $listefile
do
    if [ "Mean" = "$method" ]
    then
        echo "$chemin/SCNorm/SCNormLocaljobsend.sh $chemin/SCNorm/tmp/$DATE/$nfile $chemin/SCNorm/reference $chemin/SCNorm/SC $chemin/SCNorm/counts $chemin/SCNorm/results $chemin/SCNorm/Human_Big_GRN_032014.csv $lfc $pval Mean" >> CommandsList 
    elif [ "Sums" = "$method" ]
    then
       	echo "$chemin/SCNorm/SCNormLocaljobsend.sh $chemin/SCNorm/tmp/$DATE/$nfile $chemin/SCNorm/reference $chemin/SCNorm/SC $chemin/SCNorm/counts $chemin/SCNorm/results $chemin/SCNorm/Human_Big_GRN_032014.csv $lfc $pval Sums" >> CommandsList
    else
        echo "$chemin/SCNorm/SCNormLocaljobsend.sh $chemin/SCNorm/tmp/$DATE/$nfile $chemin/SCNorm/reference $chemin/SCNorm/SC $chemin/SCNorm/counts $chemin/SCNorm/results $chemin/SCNorm/Human_Big_GRN_032014.csv $lfc $pval Mean" >> CommandsList
        echo "$chemin/SCNorm/SCNormLocaljobsend.sh $chemin/SCNorm/tmp/$DATE/$nfile $chemin/SCNorm/reference $chemin/SCNorm/SC $chemin/SCNorm/counts $chemin/SCNorm/results $chemin/SCNorm/Human_Big_GRN_032014.csv $lfc $pval Sums" >> CommandsList
	  fi
done

exit 0