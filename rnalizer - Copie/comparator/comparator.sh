#!/bin/bash
#
#SBATCH -t 5-00                    # time (D-HH:MM)
#SBATCH -o slurm.%N.%j.comparator.out           # STDOUT
#SBATCH -e slurm.%N.%j.comparator.err           # STDERR

chemin=`pwd`

listefile=`ls comparator/param`

for nfile in $listefile
do
        sbatch -N 1 -n 1 -t 5-00 --mem 20GB --exclude=phantom-node31 comparator/Comparjobsend.sh $chemin/comparator/param/$nfile $chemin/comparator/reference $chemin/comparator/compar $chemin/comparator/counts $chemin/comparator/results $chemin/comparator/Human_Big_GRN_032014.csv 1 0.01 1
        #rm -rf 5transcriannot/star/$nfile
        #sleep 10
done
