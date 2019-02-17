#!/bin/bash
#
#SBATCH -t 7-00                    # time (D-HH:MM)
#SBATCH -o slurm.Tetramer.%N.%j.out           # STDOUT
#SBATCH -e slurm.Tetramer.%N.%j.err           # STDERR


# source activate /shared/labo5/gronemeyer4/studerf/.conda/envs/rnalizer

network=$1
outdir=$2
lfc=$3
core=$4

chemin=`pwd`

coring=$(($core/3))

Rscript --vanilla $chemin/Tetramer/GoExtract.R $outdir/ResultTetra/Reguloms $outdir/ResultTetra/Reguloms 0.01 2 $coring 17 &
Rscript --vanilla $chemin/Tetramer/GoExtract.R $outdir/ResultTetra/CoRegulListGenes $outdir/ResultTetra/CoRegulListGenes 0.01 1 $coring 14 &
Rscript --vanilla $chemin/Tetramer/goExtractDiffGenes.R $outdir/Tetrafiles $outdir/Tetrafiles 0.01 1 $coring 9 &

wait