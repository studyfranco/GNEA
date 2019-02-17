#!/bin/bash
#
#SBATCH -t 7-00                    # time (D-HH:MM)
#SBATCH -o slurm.SCNorm.%N.%j.out           # STDOUT
#SBATCH -e slurm.SCNorm.%N.%j.err           # STDERR

paramfile=$1
refdir=$2
compardir=$3
countdir=$4
resultdir=$5
NetworkFile=$6
lfc=$7
pval=$8
method=$9
core=${10}

chemin=`pwd`

source activate /shared/labo5/gronemeyer4/studerf/.conda/envs/rnalizer

XP=`sed -n "2{p;q}" $paramfile`
ref=`echo "$XP" | cut -d"," -f1`
SC=`echo "$XP" | cut -d"," -f2`
dirXP="Ref.${ref}_SC.${SC}_lfc.${lfc}_pval.${pval}_Norm.${method}"

echo "The resulta are saved in :" $dirXP

Rscript --vanilla $chemin/SCNorm/scnormV4.R $paramfile $refdir $compardir $countdir $resultdir $NetworkFile $lfc $pval $core $method

./Tetramer/TetramerLocal.sh $NetworkFile $resultdir/$dirXP/SingleCell $lfc $core

# rm $paramfile

exit 0 