#!/bin/bash
#
#SBATCH -t 5-00                    # time (D-HH:MM)
#SBATCH -o slurm.%N.%j.Comparjob.out           # STDOUT
#SBATCH -e slurm.%N.%j.Comparjob.err           # STDERR

paramfile=$1
refdir=$2
compardir=$3
countdir=$4
resultdir=$5
CellnetFile=$6
lfc=$7
pval=$8
core=$9

chemin=`pwd`

source activate /shared/labo5/gronemeyer4/studerf/.conda/envs/rnalizer

Rscript --vanilla $chemin/comparator/Deseq2Compar.R $paramfile $refdir $compardir $countdir $resultdir $CellnetFile $lfc $pval $core
Rscript --vanilla $chemin/comparator/extractGenesXP.R $paramfile $refdir $compardir $countdir $resultdir $lfc $pval $core

exit 0