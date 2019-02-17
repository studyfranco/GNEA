#!/bin/bash
#
#SBATCH -t 5-00                    # time (D-HH:MM)
#SBATCH -o slurm.%N.%j.SCNorm.out           # STDOUT
#SBATCH -e slurm.%N.%j.SCNorm.err           # STDERR

method=$1
ncore=$2
lfc=$3
pval=$4

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
        job=$(sbatch -N 1 -n $ncore -t 7-00 --mem 20GB --exclude=phantom-node31 SCNorm/SCNormjobsend.sh $chemin/SCNorm/tmp/$DATE/$nfile $chemin/SCNorm/reference $chemin/SCNorm/SC $chemin/SCNorm/counts $chemin/SCNorm/results $chemin/SCNorm/Human_Big_GRN_032014.csv $lfc $pval $ncore Mean)
    elif [ "Sums" = "$method" ]
    then
       	job=$(sbatch -N 1 -n $ncore -t 7-00 --mem 20GB --exclude=phantom-node31 SCNorm/SCNormjobsend.sh $chemin/SCNorm/tmp/$DATE/$nfile $chemin/SCNorm/reference $chemin/SCNorm/SC $chemin/SCNorm/counts $chemin/SCNorm/results $chemin/SCNorm/Human_Big_GRN_032014.csv $lfc $pval $ncore Sums)
    else
        job=$(sbatch -N 1 -n $ncore -t 7-00 --mem 20GB --exclude=phantom-node31 SCNorm/SCNormjobsend.sh $chemin/SCNorm/tmp/$DATE/$nfile $chemin/SCNorm/reference $chemin/SCNorm/SC $chemin/SCNorm/counts $chemin/SCNorm/results $chemin/SCNorm/Human_Big_GRN_032014.csv $lfc $pval $ncore Mean)
        job=$(sbatch -N 1 -n $ncore -t 7-00 --mem 20GB --exclude=phantom-node31 SCNorm/SCNormjobsend.sh $chemin/SCNorm/tmp/$DATE/$nfile $chemin/SCNorm/reference $chemin/SCNorm/SC $chemin/SCNorm/counts $chemin/SCNorm/results $chemin/SCNorm/Human_Big_GRN_032014.csv $lfc $pval $ncore Sums)
	  fi
done

exit 0